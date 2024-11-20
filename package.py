import os
import re
import stat


BASH_LINE = '#!/usr/bin/env bash\n'

def package_scripts(source_dir, source_root, outfile):
    cwd = os.getcwd()
    lines = _parse(os.path.join(cwd, source_dir, source_root))

    cc_vars = set()
    with open(outfile, 'w') as f:
        f.write(BASH_LINE)
        for line in lines:
            cc_vars.add(_get_vars(line))
            f.write(line)

    st = os.stat(outfile)
    os.chmod(outfile, st.st_mode | stat.S_IEXEC)

    with open('env', 'w') as f:
        sorted_vars = sorted(list(cc_vars))
        for var in sorted_vars:
            f.write(f'{var}\n')

    print(f"Current script is {len(''.join(lines))} (max: 8192) chars.")
    if len(''.join(lines)) > 8192:
        print("Due to windows limitiations, script must be under 8192 chars.")
        exit(1)

def _get_vars(line):
    matcher = r'(CC_[\w_]+)'
    matches = re.search(matcher, line)
    if matches and matches.groups():
        return matches.groups()[0]

    matcher = r'v_arg ([\w_]+)'
    matches = re.search(matcher, line)
    if matches and matches.groups():
        return f"CC_{matches.groups()[0]}"

    return ''

def _parse(file):
    lines = []
    with open(file, 'r') as f:
        for line in f.readlines():
            if line == BASH_LINE or line == '\n':
                continue

            script = _get_script_from_line(line)
            if script is not None:
                lines.extend(_parse(os.path.join(os.path.dirname(file), script)))
            else:
                shortened_line = _shorten_line(line)
                lines.append(shortened_line)
    return lines

def _shorten_line(line):
    return line.replace("CODECOV", "CC").replace("codecov_", "cc_")

def _get_script_from_line(line):
    matcher = r'\s*\. \.\/(\S+\.sh)$'  #. ./version.sh
    matches = re.match(matcher, line)
    if matches:
        return matches.groups()[0]

if __name__=="__main__":
    package_scripts('scripts', 'run.sh', 'dist/codecov.sh')
