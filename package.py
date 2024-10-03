import os
import re
import stat


def package_scripts(source_dir, source_root, outfile):
    cwd = os.getcwd()
    lines = _parse(os.path.join(cwd, source_dir, source_root))
    with open(outfile, 'w') as f:
        for line in lines:
            f.write(line)

    st = os.stat(outfile)
    os.chmod(outfile, st.st_mode | stat.S_IEXEC)

def _parse(file):
    lines = []
    with open(file, 'r') as f:
        for line in f.readlines():
            script = _get_script_from_line(line)
            if script is not None:
                lines.extend(_parse(os.path.join(os.path.dirname(file), script)))
            else:
                lines.append(line)
    return lines

def _get_script_from_line(line):
    matcher = r'\s*\. \.\/(\S+\.sh)$'  #. ./version.sh
    matches = re.match(matcher, line)
    if matches:
        return matches.groups()[0]

if __name__=="__main__":
    package_scripts('scripts', 'run.sh', 'dist/run.sh')
