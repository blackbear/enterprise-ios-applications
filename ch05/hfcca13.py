#!/usr/bin/env python

#  Copyright 2008-2011 Nokia Siemens Networks Oyj
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  author: terry.yinzhe@gmail.com or zhe-terry.yin@nsn.com
#

"""
source_analyzer (verion 1.3) is a simple code complexity counter without caring about the C/C++ header files.
It can deal with C/C++ & TNSDL code. It count the NLOC (lines of code without comments), CCN 
(cyclomatic complexity number) and token count of functions.
"""

DEFAULT_CCN_THRESHOLD = 15

class analysis_result:
    def __init__(self, name): self.name = name
    def __eq__(self, other): return other == self.name

class counter:
    def __init__(self):
        self.current_line = 0
        self._reset()
    def __getattr__(self, name):
        if name == "long_function_name":
            return self.return_type + self.function_name + self.parameters
    def start_new_function(self, function_name):
        self._reset()
        self.function_name = function_name
    def function_in_namespace(self, function_name):
        self.function_name = self.function_name + "::" + function_name
    def add_condition(self): self.cyclomatic_complexity += 1
    def add_token(self): self.token_count += 1
    def add_non_comment_line(self): self.NLOC += 1
    def add_to_long_name(self, app):
        self.parameters += (" " + app)
    def set_current_line(self, line):
        self.current_line = line
    def summarize(self):
        result = analysis_result(self.function_name)
        result.long_name = self.long_function_name
        result.cyclomatic_complexity = self.cyclomatic_complexity
        result.token_count = self.token_count
        result.NLOC = self.NLOC
        result.start_line = self.function_start_line
        return result    
    def _reset(self):
        self.cyclomatic_complexity = 1
        self.NLOC = 1
        self.token_count = 0
        self.function_name = ""
        self.parameters = "("
        self.return_type = ""
        self.function_start_line = self.current_line
        
class c_preprocessor1:
    def __init__(self):
        self.stack = []
    def process(self, tokens):
        for token, line in tokens:
            if not self.in_else(token):
                yield token, line
    def in_else(self, token):
        if token == '#if':
            self.stack.append(token)
        elif token == '#else':
            self.stack.append(token)
        elif token == '#endif':
            while len(self.stack) and self.stack.pop() != "#if":
                pass
        return token.startswith("#") or '#else' in self.stack
def c_preprocessor(tokens):   
    return c_preprocessor1().process(tokens)
    
class file_parser(counter):
    def __init__(self):
        self._state = self._GLOBAL
        counter.__init__(self)
    def input(self, tokens):
        for token, line in tokens:
            self.set_current_line(line)
            fun = self._read_token(token)
            if fun: yield self.summarize()
    def _GLOBAL(self, token):
        pass
                
    def _read_token(self, token):
        if token.isspace():
            self.add_non_comment_line()
        else:
            return self._state(token)
        
class c_file_parser(file_parser):
    def __init__(self):
        file_parser.__init__(self)
        self.pa_count = 0
        self.br_count = 0
            
    conditions = set(['if', 'for', 'while', '&&', '||', 'case', '?', '#if', 'catch'])
    def is_condition(self, token):
        return token in self.conditions
    def _GLOBAL(self, token):
        if token == '(':
            self.pa_count += 1
            self._state = self._DEC
        elif token == '::':
            self._state = self._NAMESPACE
        else:
            self.start_new_function(token)
    def _NAMESPACE(self, token):
            self.function_in_namespace(token)
            self._state = self._GLOBAL
        
    def _DEC(self, token):
        self.add_to_long_name(token)
        if token == '(':
            self.pa_count += 1
        elif token == ')':
            self.pa_count -= 1
            if (self.pa_count == 0):
                self._state = self._DEC_TO_IMP
    def _DEC_TO_IMP(self, token):
        if token == 'const':
            self.add_to_long_name(token)
        elif token == '{':
            self.br_count += 1
            self._state = self._IMP
        else:
            self._state = self._GLOBAL
    def _IMP(self, token):
        if token == '{':
            self.br_count += 1
        elif token == '}':
            self.br_count -= 1
            if self.br_count == 0:
                self._state = self._GLOBAL
                return True      
        else:
            if token not in '();':
                self.add_token()
            if self.is_condition(token):
                self.add_condition()
class objc_file_parser(c_file_parser):
    def __init__(self):
        c_file_parser.__init__(self)

    def _DEC_TO_IMP(self, token):
        c_file_parser._DEC_TO_IMP(self, token)
        if self._state == self._GLOBAL:
            self.start_new_function(token)
            self._state = self._OBJC_DEC_BEGIN
    def _OBJC_DEC_BEGIN(self, token):
        if token == ':':
            self._state = self._OBJC_DEC
        elif token == '{':
            self.br_count += 1
            self._state = self._IMP
        else:
            self._state = self._GLOBAL
    def _OBJC_DEC(self, token):
        if token == '(':
            self._state = self._OBJC_PARAM_TYPE
        elif token == ',':
            pass
        elif token == '{':
            self.br_count += 1
            self._state = self._IMP
        else:
            self.add_to_long_name(":"+token)
            self._state = self._OBJC_DEC_BEGIN
        
    def _OBJC_PARAM_TYPE(self, token):
        if token == ')':
            self._state = self._OBJC_PARAM
    def _OBJC_PARAM(self, token):
        self._state = self._OBJC_DEC

class sdl_file_parser(file_parser):
    def __init__(self):
        file_parser.__init__(self)
        self.last_token = ""
        self.prefix = ""
        self.statename = ""
        self.start_of_statement = True
        self.saved_process = ""
                
    def _GLOBAL(self, token):
            if token == 'PROCEDURE':
                self._state = self._DEC
            elif token == 'PROCESS':
                self._state = self._PROCESS
            elif token == 'STATE': 
                self._state = self._STATE
            elif token == 'START': 
                self.prefix = self.saved_process
                self.start_new_function(self.prefix)
                self._state = self._IMP
    def _DEC(self, token):
            self.prefix = "PROCEDURE " + token
            self.start_new_function(self.prefix)
            self._state = self._IMP
    def _PROCESS(self, token):
        self.prefix = "PROCESS " + token
        self.start_new_function(self.prefix)
        self.saved_process = self.prefix
        self._state = self._IMP
    def _STATE(self, token):
        self.statename = token
        self._state = self._BETWEEN_STATE_AND_INPUT
    def _BETWEEN_STATE_AND_INPUT(self, token):
        if token == 'INPUT':
            self._state = self._INPUT
    def _INPUT(self, token):
        if token != 'INTERNAL':
            self._state = self._IMP
            self.start_new_function(self.prefix + " STATE " + self.statename + " INPUT " + token)
    def _IMP(self, token):
        if token == 'PROCEDURE':
            self._state = self._DEC
            return False
        if token == 'ENDPROCEDURE' or token == 'ENDPROCESS' or token == 'ENDSTATE':
            self._state = self._GLOBAL
            return True
        if self.start_of_statement:     
            if token == 'STATE': 
                self._state = self._STATE
                return True     
            elif token == 'INPUT': 
                self._state = self._INPUT
                return True     
        self.add_token()
        if self.is_condition(token, self.last_token):
            self.add_condition()
        self.last_token = token
        if not token.startswith("#"):
            self.start_of_statement = (token == ';')
        
    conditions = set(['WHILE', 'AND', 'OR', '#if'])
    def is_condition(self, token, last_token):
        if token == ':' and last_token == ')':
            return True
        return token in self.conditions

def default_preprocessor(tokens):
    for token in tokens:
        yield token


def create_c_hfcca(source_code, preprocessor=default_preprocessor):
    return source_analyzer(source_code, generate_tokens, c_file_parser, preprocessor)
def create_sdl_hfcca(source_code, preprocessor=default_preprocessor):
    return source_analyzer(source_code, generate_tokens, sdl_file_parser, preprocessor)
def create_objc_hfcca(source_code, preprocessor=default_preprocessor):
    return source_analyzer(source_code, generate_tokens, objc_file_parser, preprocessor)

class source_analyzer(list):
    def __init__(self, source_code, tokenizer, file_parser, preprocessor=default_preprocessor):
        tokens = tokenizer(source_code)
        preprocessed_tokens = preprocessor(tokens)
        file = file_parser()
        
        for fun in file.input(preprocessed_tokens):
            self.append(fun)
        self.LOC = file.current_line
        self._summarize()
    def _summarize(self):
        self.average_NLOC = 0
        self.average_CCN = 0
        self.average_token = 0
        
        nloc = 0
        ccn = 0
        token = 0
        for fun in self:
            nloc += fun.NLOC
            ccn += fun.cyclomatic_complexity
            token += fun.token_count
        fc = len(self)
        if fc > 0:
            self.average_NLOC = nloc / fc
            self.average_CCN = ccn / fc
            self.average_token = token / fc
    
        self.NLOC = nloc
        self.CCN = ccn
        self.token = token

import re

c_pattern = re.compile(r".*\.(c|C|cpp|CPP|CC|cc|mm)$")
sdl_pattern = re.compile(r".*\.(sdl|SDL)$")
objc_pattern = re.compile(r".*\.(m)$")

hfcca_language_infos = {
                 'c/c++': {
                  'name_pattern': c_pattern,
                  'creator':create_c_hfcca},   
                    
                 'sdl' : {
                  'name_pattern': sdl_pattern,
                  'creator':create_sdl_hfcca},
                  
                  'objC' : {
                  'name_pattern': objc_pattern,
                  'creator':create_objc_hfcca}
            }

def get_creator_by_file_name(filename):
        for lan in hfcca_language_infos:
            info = hfcca_language_infos[lan]
            if info['name_pattern'].match(filename):
                return info['creator']
def file_hfcca(filename, use_preprocessor=None):
        f = open(filename)
        code = f.read()
        f.close()
        creator = get_creator_by_file_name(filename)
        if creator:
            preprocessor = default_preprocessor
            if use_preprocessor:
                preprocessor = c_preprocessor
            source_analyzer = creator(code, preprocessor)
            source_analyzer.filename = filename
            return source_analyzer
       
c_token_pattern = re.compile(r"(\w+|/\*|//|:=|::|#\s*define|#\s*if|#\s*else|#\s*endif|#\s*\w+|[!%^&\*\-=+\|\\<>/\]\+]+|.)", re.M | re.S)

def generate_tokens(source_code):
    for t, l in _generate_c_tokens_from_code(source_code):
        if not t.startswith('#define') and not t.startswith('/*') and not t.startswith('//') :
            yield t, l
            
def _generate_c_tokens_from_code(source_code):
    index = 0
    line = 1
    while 1:
        m = c_token_pattern.match(source_code, index)
        if not m:
            break
        token = m.group(0)
        if token == '\n': line += 1
        
        if token.startswith("#"):
            token = "#" + token[1:].strip()
            
        if token == "#define":
            while(1):
                bindex = index + 1
                index = source_code.find('\n', bindex)  
                if index == -1:
                    break
                if not source_code[bindex:index].rstrip().endswith('\\'):
                    break
            if index == -1:
                break
            token = source_code[m.start(0):index]
        elif token == '/*':
            index = source_code.find("*/", index)
            if index == -1:
                break
            index += 2
            token = source_code[m.start(0):index]
        elif token == '//' or token == '#if' or token == '#endif':
            index = source_code.find('\n', index)  
            if index == -1:
                break
        elif token == '"' or token == '\'':
            while(1):
                index += 1
                index = source_code.find(token, index)  
                if index == -1 or source_code[index - 1] != '\\':
                    break
            if index == -1:
                break
            token = source_code[m.start(0):index + 1]
            index = index + 1
        else:
            index = m.end(0)
        line += (len(token.splitlines()) - 1)
        if not token.isspace() or token == '\n':
            yield token, line
         

import os

def match_patterns(str, patterns):
    for p in patterns:
        if p.match(str):
            return True
    return False
    
def iterate_files(SRC_DIRs, exclude_patterns):
    for SRC_DIR in SRC_DIRs:
        if os.path.isfile(SRC_DIR):
            yield SRC_DIR
        else:
            for root, dirs, files in os.walk(SRC_DIR, topdown=False):
                for filename in files:
                    if get_creator_by_file_name(filename):
                        if match_patterns(filename, exclude_patterns):
                            continue
                        full_path_name = os.path.join(root, filename)
                        yield full_path_name

import itertools
def analyze(paths, exclude_patterns, use_preprocessor=None, threads=1):
    if 0:
        import multiprocessing
        it = multiprocessing.Pool(processes=threads)
        return it.imap(file_hfcca, iterate_files(paths, exclude_patterns))
    return itertools.imap(file_hfcca, iterate_files(paths, exclude_patterns), itertools.repeat(use_preprocessor))


import sys

def print_function_info(fun, filename, option):
    name = fun.name
    if option.verbose:
        name = fun.long_name
    print "%6d%6d%6d %s@%s@%s"%(fun.NLOC, fun.cyclomatic_complexity, fun.token_count, name, fun.start_line, filename)
def output_result(r, option):
    saved_result = []
    if (option.warnings_only):
        saved_result = r
    else:
        print "=============================================================="
        print "NLOC    CCN   token          function@line@file"
        print "--------------------------------------------------------------"
        for f in r:
            saved_result.append(f)
            for fun in f:
                print_function_info(fun, f.filename, option)
        print "--------------------------------------------------------------"
        print "%d file analyzed." % (len(saved_result))
        print "=============================================================="
        print "LOC    Avg.NLOC AvgCCN Avg.ttoken  function_cnt    file"
        print "--------------------------------------------------------------"
        for f in saved_result:
            print "%7d%7d%7d%10d%10d     %s"%(f.LOC, f.average_NLOC, f.average_CCN, f.average_token, len(f), f.filename)
    warning_count = 0
    print
    print "!!!! Warnings (CCN > %d) !!!!" % option.CCN
    print "=============================================================="
    print "NLOC    CCN   token          function@file"
    print "--------------------------------------------------------------"
    cnt = 0
    for f in saved_result:
        for fun in f:
            cnt += 1
            if fun.cyclomatic_complexity > option.CCN:
                warning_count += 1
                print_function_info(fun, f.filename, option)
    percent = 100
    if cnt > 0:
        percent = (warning_count * 1000) / cnt
    print >> sys.stderr, "Total warning: (%d/%d, %d.%d%%)" % (warning_count, cnt, percent / 10, percent % 10)
    if option.number < warning_count:
        sys.exit(1)

def xml_output(result, options):
    import xml.dom.minidom

    impl = xml.dom.minidom.getDOMImplementation()
    doc = impl.createDocument(None, "cppncss", None)
    root = doc.documentElement

    measure = doc.createElement("measure")
    measure.setAttribute("type", "Function")
    labels = doc.createElement("labels")
    label1 = doc.createElement("label")
    text1 = doc.createTextNode("Nr.")
    label1.appendChild(text1)
    label2 = doc.createElement("label")
    text2 = doc.createTextNode("NCSS")
    label2.appendChild(text2)
    label3 = doc.createElement("label")
    text3 = doc.createTextNode("CCN")
    label3.appendChild(text3)
    labels.appendChild(label1)
    labels.appendChild(label2)
    labels.appendChild(label3)
    measure.appendChild(labels)
    
    Nr = 0
    total_func_ncss = 0
    total_func_ccn = 0
    
    for file in result:
        file_name = file.filename
        for func in file:
            Nr += 1
            item = doc.createElement("item")
            item.setAttribute("name", "%s(...) at %s:0" % (func.name, file_name))
            value1 = doc.createElement("value")
            text1 = doc.createTextNode(str(Nr))
            value1.appendChild(text1)
            item.appendChild(value1)
            value2 = doc.createElement("value")
            text2 = doc.createTextNode(str(func.NLOC))
            value2.appendChild(text2)
            item.appendChild(value2)
            value3 = doc.createElement("value")
            text3 = doc.createTextNode(str(func.cyclomatic_complexity))
            value3.appendChild(text3)
            item.appendChild(value3)
            measure.appendChild(item)
            total_func_ncss += func.NLOC
            total_func_ccn += func.cyclomatic_complexity
        
        if Nr != 0:
            average_ncss = doc.createElement("average")
            average_ncss.setAttribute("lable", "NCSS")
            average_ncss.setAttribute("value", str(total_func_ncss / Nr))
            measure.appendChild(average_ncss)
            
            average_ccn = doc.createElement("average")
            average_ccn.setAttribute("lable", "CCN")
            average_ccn.setAttribute("value", str(total_func_ccn / Nr))
            measure.appendChild(average_ccn)
    
    root.appendChild(measure)

    measure = doc.createElement("measure")
    measure.setAttribute("type", "File")
    labels = doc.createElement("labels")
    label1 = doc.createElement("label")
    text1 = doc.createTextNode("Nr.")
    label1.appendChild(text1)
    label2 = doc.createElement("label")
    text2 = doc.createTextNode("NCSS")
    label2.appendChild(text2)
    label3 = doc.createElement("label")
    text3 = doc.createTextNode("CCN")
    label3.appendChild(text3)
    label4 = doc.createElement("label")
    text4 = doc.createTextNode("Functions")
    label4.appendChild(text4)
    labels.appendChild(label1)
    labels.appendChild(label2)
    labels.appendChild(label3)
    labels.appendChild(label4)
    measure.appendChild(labels)
    
    file_NR = 0
    file_total_ncss = 0
    file_total_ccn = 0
    file_total_funcs = 0
    
    for file in result:
        file_NR += 1
        item = doc.createElement("item")
        item.setAttribute("name", file.filename)
        value1 = doc.createElement("value")
        text1 = doc.createTextNode(str(file_NR))
        value1.appendChild(text1)
        item.appendChild(value1)
        value2 = doc.createElement("value")
        text2 = doc.createTextNode(str(file.NLOC))
        value2.appendChild(text2)
        item.appendChild(value2)
        value3 = doc.createElement("value")
        text3 = doc.createTextNode(str(file.CCN))
        value3.appendChild(text3)
        item.appendChild(value3)
        value4 = doc.createElement("value")
        text4 = doc.createTextNode(str(len(file)))
        value4.appendChild(text4)
        item.appendChild(value4)
        measure.appendChild(item)
        file_total_ncss += file.NLOC
        file_total_ccn += file.CCN
        file_total_funcs += len(file)
    
    if file_NR != 0:
            average_ncss = doc.createElement("average")
            average_ncss.setAttribute("lable", "NCSS")
            average_ncss.setAttribute("value", str(file_total_ncss / file_NR))
            measure.appendChild(average_ncss)
            
            average_ccn = doc.createElement("average")
            average_ccn.setAttribute("lable", "CCN")
            average_ccn.setAttribute("value", str(file_total_ccn / file_NR))
            measure.appendChild(average_ccn)
            
            average_funcs = doc.createElement("average")
            average_funcs.setAttribute("lable", "Functions")
            average_funcs.setAttribute("value", str(file_total_funcs / file_NR))
            measure.appendChild(average_funcs)
            
    sum_ncss = doc.createElement("sum")
    sum_ncss.setAttribute("lable", "NCSS")
    sum_ncss.setAttribute("value", str(file_total_ncss))
    measure.appendChild(sum_ncss)
    sum_ccn = doc.createElement("sum")
    sum_ccn.setAttribute("lable", "CCN")
    sum_ccn.setAttribute("value", str(file_total_ccn))
    measure.appendChild(sum_ccn)
    sum_funcs = doc.createElement("sum")
    sum_funcs.setAttribute("lable", "Functions")
    sum_funcs.setAttribute("value", str(file_total_funcs))
    measure.appendChild(sum_funcs)
            
    root.appendChild(measure)
    
    xmlString = doc.toprettyxml()
    return xmlString


from optparse import OptionParser
def main(argv):
    parser = OptionParser()
    parser.add_option("-v", "--verbose",
            help="Output in verbose mode (long function name)",
            action="store_true",
            dest="verbose",
            default=False)
    parser.add_option("-C", "--CCN",
            help="Threshold for cyclomatic complexity number warning. functions with CCN bigger than this number will be shown in warning",
            action="store",
            type="int",
            dest="CCN",
            default=DEFAULT_CCN_THRESHOLD)
    parser.add_option("-w", "--warnings_only",
            help="Show warnings only",
            action="store_true",
            dest="warnings_only",
            default=False)
    parser.add_option("-i", "--ignore_warnings",
            help="If the number of warnings is equal or less than the number, the tool will exit normally, otherwize it will generate error. Useful in makefile when improving legacy code.",
            action="store",
            type="int",
            dest="number",
            default=0)
    parser.add_option("-x", "--exclude",
            help="Exclude data files that match this regular expression",
            action="append",
            dest="exclude",
            default=[])
    parser.add_option("-X", "--xml",
            help="Generate XML in cppncss style instead of the normal tabular output. Useful to generate report in Hudson server",
            action="store_true",
            dest="xml",
            default=None)
    parser.add_option("-p", "--preprocess",
            help="Use preprocessor, always ignore the #else branch. By default, source_analyzer just ignore any preprocessor statement.",
            action="store_true",
            dest="use_preprocessor",
            default=None)
    parser.add_option("-t", "--working_threads",
            help="number of working threads. The default value is 1.",
            action="store",
            type="int",
            dest="working_threads",
            default=1)

    parser.usage = "source_analyzer.py [options] [PATH or FILE] [PATH] ... "
    parser.description = __doc__
    (options, args) = parser.parse_args(args=sys.argv)
    
    if len(args) == 1:
        paths = ["."]
    else:
        paths = args[1:]
    
    exclude_patterns = [re.compile(p) for p in options.exclude]
    files = iterate_files(paths, exclude_patterns)
    if options.working_threads > 1:
        import multiprocessing
        it = multiprocessing.Pool(processes=options.working_threads)
        r = it.imap_unordered(file_hfcca, files)
    else:
        r = itertools.imap(file_hfcca, files, itertools.repeat(options.use_preprocessor))
    if options.xml:
        print xml_output([f for f in r], options)
    else:
        output_result(r, options)
if __name__ == "__main__":
    main(sys.argv[1:])

#
# Unit Test
#
import unittest
class Test_c_hfcca(unittest.TestCase):
    def test_empty(self):
        result = create_c_hfcca("")
        self.assertEqual(0, len(result))
    def test_no_function(self):
        result = create_c_hfcca("#include <stdio.h>\n")
        self.assertEqual(0, len(result))
    def test_one_function(self):
        result = create_c_hfcca("int fun(){}")
        self.assertEqual(1, len(result))
        self.assertTrue("fun" in result)
        self.assertEqual(1, result[0].cyclomatic_complexity)
    def test_two_function(self):
        result = create_c_hfcca("int fun(){}\nint fun1(){}")
        self.assertEqual(2, result.LOC)
        self.assertEqual(2, len(result))
        self.assertTrue("fun" in result)
        self.assertTrue("fun1" in result)
        self.assertEqual(1, result[0].start_line)
        self.assertEqual(2, result[1].start_line)
    def test_function_with_content(self):
        result = create_c_hfcca("int fun(xx oo){int a; a= call(p1,p2);}")
        self.assertEqual(1, len(result))
        self.assertTrue("fun" in result)
        self.assertEqual(1, result[0].cyclomatic_complexity)
        self.assertEqual("fun( xx oo )", result[0].long_name)
    def test_one_function_with_content(self):
        result = create_c_hfcca("int fun(){if(a){xx;}}")
        self.assertEqual(2, result[0].cyclomatic_complexity)
        self.assertEqual(1, result[0].NLOC)
        self.assertEqual(3, result[0].token_count)
    def test_one_function_with_question_mark(self):
        result = create_c_hfcca("int fun(){return (a)?b:c;}")
        self.assertEqual(2, result[0].cyclomatic_complexity)
    def test_one_function_with_and(self):
        result = create_c_hfcca("int fun(){if(a&&b){xx;}}")
        self.assertEqual(3, result[0].cyclomatic_complexity)
    def test_example1(self):
        result = create_c_hfcca(example1)
        self.assertEqual(3, result[0].cyclomatic_complexity)
    def test_example_macro(self):
        result = create_c_hfcca(example_macro)
        self.assertEqual(0, len(result))
        
class Test_cpp_hfcca(unittest.TestCase):
    def test_one_function(self):
        result = create_c_hfcca("int abc::fun(){}")
        self.assertEqual(1, len(result))
        self.assertTrue("abc::fun" in result)
        self.assertEqual("abc::fun( )", result[0].long_name)
        self.assertEqual(1, result[0].cyclomatic_complexity)
    def test_one_function_with_const(self):
        result = create_c_hfcca("int abc::fun()const{}")
        self.assertEqual(1, len(result))
        self.assertTrue("abc::fun" in result)
        self.assertEqual("abc::fun( ) const", result[0].long_name)
        self.assertEqual(1, result[0].cyclomatic_complexity)

    def test_one_function_in_class(self):
        result = create_c_hfcca("class c {~c(){}}; int d(){}")
        self.assertEqual(2, len(result))
        self.assertTrue("c" in result)
        self.assertTrue("d" in result)

class Test_sdl_hfcca(unittest.TestCase):
    def test_empty(self):
        result = create_sdl_hfcca("")
        self.assertEqual(0, len(result))
    def test_process(self):
        result = create_sdl_hfcca("PROCESS pofcap\n ENDPROCESS;")
        self.assertEqual(1, len(result))
        self.assertTrue('PROCESS pofcap' in result)
    def test_one_function(self):
        result = create_sdl_hfcca("PROCEDURE xxx\n ENDPROCEDURE;");
        self.assertEqual(1, len(result))
        self.assertTrue("PROCEDURE xxx" in result)
        self.assertEqual(1, result[0].cyclomatic_complexity)
        self.assertEqual(0, result[0].token_count)
    def test_one_function_with_condition(self):
        result = create_sdl_hfcca(example_sdl_procedure);
        self.assertEqual(1, len(result))
        self.assertTrue("PROCEDURE send_swo_msgs__r" in result)
        self.assertEqual(7, result[0].cyclomatic_complexity)
        self.assertEqual(173, result[0].token_count)
    def test_one_function_with_array(self):
        result = create_sdl_hfcca("""
        PROCEDURE send_swo_msgs__r;
        START;
            TASK array(0):= 1;
        ENDPROCEDURE;
        """);
        self.assertEqual(1, len(result))
        self.assertEqual(1, result[0].cyclomatic_complexity)
    def test_process_with_content(self):
        result = create_sdl_hfcca(example_sdl_process);
        self.assertEqual(5, len(result))
        self.assertTrue("PROCEDURE send_swo_msgs__r" in result)
        self.assertTrue("PROCESS pofsrt" in result)
        self.assertTrue("PROCESS pofsrt STATE start_state INPUT supervision_msg_s" in result)
        self.assertTrue("PROCESS pofsrt STATE start_state1 INPUT supervision_msg_s2" in result)
        self.assertEqual(2, result[1].cyclomatic_complexity)

class Test_objc_hfcca(unittest.TestCase):
    def test_empty(self):
        result = create_objc_hfcca("")
        self.assertEqual(0, len(result))
    def test_no_function(self):
        result = create_objc_hfcca("#import <unistd.h>\n")
        self.assertEqual(0, len(result))
    def test_one_c_function(self):
        result = create_objc_hfcca("int fun(int a, int b) const{}")
        self.assertTrue("fun" in result)
    def test_one_objc_function(self):
        result = create_objc_hfcca("-(void) foo {}")
        self.assertTrue("foo" in result)
    def test_one_objc_function_with_param(self):
        result = create_objc_hfcca("-(void) replaceScene: (CCScene*) scene {}")
        self.assertTrue("replaceScene" in result)
    def test_one_objc_function_with_multiple_param(self):
        result = create_objc_hfcca("-(void) replaceScene: (CCScene*) scene, (int)a {}")
        self.assertTrue("replaceScene" in result)
    def test_one_objc_function_with_subclss(self):
        result = create_objc_hfcca("- (BOOL)scanJSONObject:(id *)outObject error:(NSError **)outError {}")
        self.assertTrue("scanJSONObject" in result)


class Test_parser_token(unittest.TestCase):
    def get_tokens(self, source_code):
        return [x for x, l in generate_tokens(source_code)]
    def get_tokens_and_line(self, source_code):
        return [x for x in generate_tokens(source_code)]
    def test_empty(self):
        tokens = self.get_tokens("")
        self.assertEqual(0, len(tokens))
    def test_one_digit(self):
        tokens = self.get_tokens("1")
        self.assertEqual(['1'], tokens)
    def test_operators(self):
        tokens = self.get_tokens("-;")
        self.assertEqual(['-', ';'], tokens)
    def test_operators1(self):
        tokens = self.get_tokens("-=")
        self.assertEqual(['-='], tokens)
    def test_operators2(self):
        tokens = self.get_tokens(">=")
        self.assertEqual(['>='], tokens)

    def test_more(self):
        tokens = self.get_tokens("int a{}")
        self.assertEqual(['int', "a", "{", "}"], tokens)
    def test_or(self):
        tokens = self.get_tokens("||")
        self.assertEqual(['||'], tokens)
    def test_comment(self):
        tokens = self.get_tokens("/***\n**/")
        self.assertEqual([], tokens)
        tokens = self.get_tokens("//aaa\n")
        self.assertEqual(['\n'], tokens)
    def test_string(self):
        tokens = self.get_tokens(r'""')
        self.assertEqual(['""'], tokens)
        tokens = self.get_tokens(r'"x\"xx")')
        self.assertEqual(['"x\\"xx"', ')'], tokens)
    def test_define(self):
        tokens = self.get_tokens('''#define xx()\
                                      abc
                                    int''')
        self.assertEqual(['\n', 'int'], tokens)
       
    def test_line_number(self):
        tokens = self.get_tokens_and_line(r'abc')
        self.assertEqual(('abc', 1), tokens[0])
    def test_line_number2(self):
        tokens = self.get_tokens_and_line('abc\ndef')
        self.assertTrue(('def', 2) in tokens)
    def test_with_mutiple_line_string(self):
        tokens = self.get_tokens_and_line('"sss\nsss" t')
        self.assertTrue(('t', 2) in tokens)
    def test_with_cpp_comments(self):
        tokens = self.get_tokens_and_line('//abc\n t')
        self.assertTrue(('t', 2) in tokens)
    def test_with_line_continuer_comments(self):
        tokens = self.get_tokens_and_line('#define a \\\nb\n t')
        self.assertTrue(('t', 3) in tokens)
    def test_define2(self):
        tokens = self.get_tokens_and_line(r''' # define yyMakeArray(ptr, count, size)     { MakeArray (ptr, count, size); \
                       yyCheckMemory (* ptr); }
                       t
''')
        self.assertTrue(('t', 3) in tokens)
    def test_with_c_comments(self):
        tokens = self.get_tokens_and_line('/*abc\n*/ t')
        self.assertTrue(('t', 2) in tokens)

example1 = r'''
int startup(u_short *port)
{
 if (*port == 0)  /* if dynamically allocating a port */
 {
  socklen_t namelen = sizeof(name);
#ifdef abc
  *port = ntohs(name.sin_port);
#endif
 }
 return(httpd);
}
'''

example_macro = r'''
#define MTP_CHECK                                                             \
   if (mea_data->which_data != MTP_WHICH_DATA_T_NONE_C) {                     \
   phys_address_t np;                                                         \
   }
'''

example_sdl_procedure = '''
/**************************************************************************/
PROCEDURE send_swo_msgs__r;
/*
 * Send the given switchover message to POFFIC in all computers in the target list.
 **************************************************************************/
FPAR
    IN/OUT  targets  targets__t,
    IN      msg_num  message_number_t;

DCL
    i     dword := 0,
    c_i   dword,
    msg_group message_group_t,
    activity_signal byte := msg_attr_t_normal_priority_c,
    ppid  pid;

START;
    DECISION routing_state__pv;
    ( routing_state_t_active_c ):
       TASK activity_signal := msg_attr_t_is_active__c;
    ENDDECISION;

    TASK  ppid := SELF;
    WHILE i < targets.item_count;
       TASK  set_pid_computer_r( ppid, targets.target(i).addr );
       TASK  c_i := 0,
             msg_group := direct_delivery_gi;

       WHILE c_i < 2;
          DECISION targets.target(i).chan(c_i);
          ( T ):
             DECISION msg_num;
             ( NUMBER_FROM( pof_deny_messages_s )):
                OUTPUT pof_deny_messages_s TO ppid,
                       SET GROUP = msg_group;
             ( NUMBER_FROM( pof_allow_messages_s )):
                OUTPUT pof_allow_messages_s TO ppid,
                       SET GROUP = msg_group, PRIORITY = activity_signal;
             ENDDECISION;
          ENDDECISION;
          TASK c_i := c_i + 1,
               msg_group := rt_direct_delivery_gi;
       ENDWHILE;

       TASK i := i + 1;
    ENDWHILE;
ENDPROCEDURE send_swo_msgs__r;
'''

example_sdl_process = r'''
PROCESS pofsrt
  COMMENT '@(#)SID: POFSRTGX.SDL 2.1-0 06/07/11';
/*
 *  Environment:
 *      DXSYST PHRSYB AUUSEB POFFIC
 *
 *  Description:
 *      This is the sender hand prefix of the ATM Post
 *      Office prefix family.
 *
 *  COPYRIGHT (c) 1995 NOKIA TELECOMMUNICATIONS OY FINLAND
 */

DCL
  addr_range addr_range_t;

PROCEDURE send_swo_msgs__r;
START;
    TASK  ppid := SELF;
ENDPROCEDURE send_swo_msgs__r;
START;
  /* announce to DMXRTE */
  DECISION post_office_announcement_r( post_district_index_t_atm_c,
           addr_range,
           pof_advisable_msg_len__c - sizeof(buffer_bottom_t),
           pof_ack_waiting_time__c  );
    ( success_ec ):
      TASK /* nop */;
    ELSE:
      TASK /* hanskat tiskiin */;
  ENDDECISION;
  NEXTSTATE start_state
    COMMENT 'Nuthin fancy here';

/******************************************************/
STATE start_state
  COMMENT 'Wait for the first supervision message';

  INPUT supervision_msg_s(*);
    OUTPUT supervision_ack_s( INPUT ) TO SENDER;
    TASK pofsrt__r; /* call the actual code */
    NEXTSTATE -; /* this is actually never reached */
ENDSTATE start_state
STATE start_state1
  COMMENT 'Wait for the first supervision message';

#if (tr)
  INPUT supervision_msg_s1(*);
    OUTPUT supervision_ack_s( INPUT ) TO SENDER;
    TASK pofsrt__r; /* call the actual code */
    NEXTSTATE -; /* this is actually never reached */
#endif
  INPUT INTERNAL supervision_msg_s2(*);
    OUTPUT supervision_ack_s( INPUT ) TO SENDER;
    TASK pofsrt__r; /* call the actual code */
    NEXTSTATE -; /* this is actually never reached */
ENDSTATE start_state
  COMMENT 'Hand prefix started';
ENDPROCESS pofsrt;
'''

