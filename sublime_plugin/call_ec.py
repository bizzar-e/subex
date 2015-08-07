#coding=utf-8
import sublime, sublime_plugin
import subprocess
import re
import base64

import time

import logging
import sys
sys.path.append('c:\Python27\Lib\site-packages\\')

from concurrent.futures import ThreadPoolExecutor as Pool

import codecs

start_time = time.time()

glob_fname = 'nil'
glob_orig_buffer = None

glob_isPerlReturn = False

glob_tcnt = 0

glob_orig_file = ''

glob_stage = 1

interrupted_by_perl_error = False

tmp_fname = '../tmp/tmp1.dat'

tmp_fname1 = 'c:\\sublime\\Data\\Packages\\User\\Meta\\tmp\\tmp1.dat'

def xstr(s):
    if s is None: return 'untitled'
    return str(s)

def check_output(*popenargs, **kwargs):
    r"""Run command with arguments and return its output as a byte string.

    Backported from Python 2.7 as it's implemented as pure python on stdlib.

    >>> check_output(['/usr/bin/python', '--version'])
    Python 2.6.2
    """

    process = subprocess.Popen(stdout=subprocess.PIPE, stderr=subprocess.PIPE, *popenargs, **kwargs)

    output, perl_err = process.communicate()
    retcode = process
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        error = subprocess.CalledProcessError(retcode, cmd)
        error.output = output

        print "[ERROR] Perl returned an error:\n" + "\"" + perl_err.rstrip() + "\""

        output = None

        output = perl_err.rstrip()

    return output

info = logging.getLogger(__name__).info

def callback(future):
    global glob_isPerlReturn
    global glob_orig_buffer

    global glob_fname

    global interrupted_by_perl_error

    if future.exception() is not None:
        info("got exception: %s" % future.exception())
    else:

        if future.result() is None:
            print "[ERORR] Perl returned an error instead of a result"

            interrupted_by_perl_error = True

        else:

            glob_fname = future.result()

            print "Perl executed " + glob_fname

            glob_isPerlReturn = True

def main(cmd, args):

    logging.basicConfig(
        level=logging.INFO,
        format=("%(relativeCreated)04d %(process)05d %(threadName)-10s "
                "%(levelname)-5s %(msg)s"))

    pool = Pool(max_workers=1)

    arg1 = tmp_fname
    arg2 = 'arg2'

    stage_file_name = cmd

    if (glob_stage == 1):

        f = pool.submit(check_output, ["ec-perl", "-w", stage_file_name, args, arg2], shell=True)
        print "stage 1 started. Initiate call to" + stage_file_name
        print "Stage is " + str(glob_stage)
    else:

        f = pool.submit(check_output, ["ec-perl", stage_file_name, " ", args, arg2], shell=True)
        print "stage 2 started. Initiate call to" + stage_file_name + " " + args + " " + arg2 + "'"
        print "Stage is " + str(glob_stage)

    f.add_done_callback(callback)
    pool.shutdown(wait=False)

class CallEcCommand(sublime_plugin.TextCommand):

    def run(self, view):

        global glob_fname
        global glob_orig_buffer

        global glob_isPerlReturn
        global glob_orig_file

        global t

        print "async_call"
        views = sublime.active_window().views()

        text = self.view.substr(sublime.Region(0, self.view.size()))

        t = text.split("---"); 
        print 't[0]' + t[0] + '\nt[1]' + t[1] + '\nt[2]' + t[2] 

        with codecs.open(tmp_fname1, 'w', encoding='utf8') as altf:
            altf.write(text)
        altf.close()

        main("c:\sublime\Data\Packages\User\Meta\pl\ec_parser.pl", "_arg1")

        glob_isPerlReturn = False

        self.handle_thread()

    def handle_thread(self):
        global glob_tcnt
        global glob_orig_buffer
        global glob_isPerlReturn

        w_time = 30

        delta_time = 1000

        if interrupted_by_perl_error:
            print "[INFO] Plugin was interrupted by perl error; Stage is : " + str(glob_stage)

            interrupted_by_perl_error = False

            glob_tcnt = 0

            glob_isPerlReturn = False

            if (glob_stage==1): 
                glob_stage = 2
                self.handle_thread()

            if (glob_stage==2): glob_stage = 1
            
            return

        v = self.view

        if glob_isPerlReturn:

            if (glob_stage==1):
                print "stage 1 is over"
                print "Stage is " + str(glob_stage)
                glob_stage=2

                print "Commands from parser: " + glob_fname

                c = glob_fname.split(' ')

                for x in c:
                    print "Params from parser >> " + x

                print 'c[0] ' + c[0]

                print 'c[1] ' + c[1]
                print 'c[2] ' + c[2]
                print 'c[3] ' + c[3]

                argv =  c[1] + ' ' + c[2] + ' ' + c[3]
                print "argv " + argv

                main(c[0], argv)
                
                glob_tcnt = 0
                glob_isPerlReturn = False

                self.handle_thread()

                return

            if (glob_stage==2):

               print "Result received in ~" + str(glob_tcnt * delta_time) + " ms"

                glob_tcnt = 0
                glob_isPerlReturn = False

                data = unicode(glob_fname, errors='replace')

                data = re.sub("\r", "", data)

                data = re.sub("[\r\n]DEBUG[\r\n]+", "", data)

                if re.search("-inbuf", t[0]):

                    edit = v.begin_edit()

                    text = v.substr(sublime.Region(0, v.size()))

                    text1 = v.substr(sublime.Region(0, 124))
                    text2 = v.substr(sublime.Region(125, v.size()))

                    entire_buffer_region = sublime.Region(0, v.size())
                    v.erase(edit, entire_buffer_region)

                    print "data is " + data
                    result = data + "\n" + text2

                    bf = t[0] + "---\n" + "Done" + "\n---" + "\n" + data

                    v.insert(edit, 0, bf)

                    v.end_edit(edit)
                
                else:

                    sublime.active_window().run_command("new_file")
                    views = sublime.active_window().views()

                    cnt = 0
                    for el in views:
                        if el.buffer_id() == self.view.buffer_id():
                            print "Number of view: " + str(cnt)
                            v_idx = cnt
                        else: cnt += 1

                    t_idx = v_idx + 1

                    views[t_idx].set_scratch(True)

                    edit = views[t_idx].begin_edit()
                    views[t_idx].insert(edit, 0, data)
                    views[t_idx].end_edit(edit)

                return

        else:

            bf = t[0] + "---\n" + str(glob_tcnt) + "\n---" + t[2]
          
            edit = v.begin_edit()

            entire_buffer_region = sublime.Region(0, v.size())
            v.erase(edit, entire_buffer_region)

            v.insert(edit, 0, bf)
                
            v.end_edit(edit)

            if glob_tcnt < w_time:
                sublime.set_timeout(lambda: self.handle_thread(), delta_time)
                glob_tcnt += 1
            else:

                print "[ERROR] Result is not received in " + str(glob_tcnt * delta_time) + " ms"
                glob_tcnt = 0

        return