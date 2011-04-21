from Pymacs import lisp

def replace_region(replacer):
    start = lisp.point()
    end = lisp.mark(True)
    if start > end:
        start, end = end, start
    text = lisp.buffer_substring(start, end)

    replacement = replacer(text)

    lisp.delete_region(start, end)
    lisp.insert(replacement)

def expand_regex(s):
    output = []
    for c in s.lower():
        output.append(c + c.upper())
    return '[' + ']['.join(output) + ']'
def do_expand_regex():
    replace_region(expand_regex)

interactions = {do_expand_regex: ''}
