import os
import re
import stat

SH_LINE = "#!/bin/sh\n"


def package_scripts(source_dir, source_root, outfile):
    cwd = os.getcwd()
    lines = _parse(os.path.join(cwd, source_dir, source_root))

    cc_vars = set()
    with open(outfile, "w") as f:
        f.write(SH_LINE)
        for line in lines:
            cc_vars.add(_get_vars(line))
            f.write(line)

    st = os.stat(outfile)
    os.chmod(outfile, st.st_mode | stat.S_IEXEC)

    with open("env", "w") as f:
        sorted_vars = sorted(list(cc_vars))
        for var in sorted_vars:
            f.write(f"{var}\n")


def _get_vars(line):
    matcher = r"(CODECOV_[\w_]+)"
    matches = re.search(matcher, line)
    if matches and matches.groups():
        return matches.groups()[0]

    return ""


def _parse(file):
    lines = []
    with open(file, "r") as f:
        for line in f.readlines():
            if line == "\n" or line == SH_LINE:
                continue

            script = _get_script_from_line(line)
            if script is not None:
                lines.extend(_parse(os.path.join(os.path.dirname(file), script)))
            else:
                lines.append(line)
    return lines


def _get_script_from_line(line):
    matcher = r"\s*\. \.\/(\S+\.sh)$"  # . ./version.sh
    matches = re.match(matcher, line)
    if matches:
        return matches.groups()[0]


if __name__ == "__main__":
    package_scripts("scripts", "run.sh", "dist/codecov.sh")
