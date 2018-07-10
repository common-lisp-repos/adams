;;
;;  adams  -  Remote system administration tools
;;
;;  Copyright 2013,2014 Thomas de Grivel <thomas@lowh.net>
;;
;;  Permission to use, copy, modify, and distribute this software for any
;;  purpose with or without fee is hereby granted, provided that the above
;;  copyright notice and this permission notice appear in all copies.
;;
;;  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;;  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;;  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;;  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;;  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;;  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;;  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;;

(in-package :adams)

(in-re-readtable)

(define-syntax ls<1>-l--full-time (mode
                                   (#'sh-parse-integer links)
                                   owner
                                   group
                                   (#'sh-parse-integer size)
                                   (#'chronicity:parse time)
                                   name)
  #~|^([-a-zA-Z]{10})\s+([0-9]+)\s+(\S+)\s+(\S+)\s+([0-9]+)\s+(\S+ \S+ \S+)\s+(.+)$|
  "Syntax for `ls -l --full-time` output. See ls(1).")

(defmethod probe-vnode-using-ls ((vnode vnode) (os os-linux))
  (let ((id (resource-id vnode))
        (ensure :absent))
    (multiple-value-bind (mode links owner group size mtime)
        (with-ls<1>-l--full-time (mode links owner group size mtime name)
            (ls "-ld --full-time" id)
          (when (and name (string= id (the string name)))
            (setq mode (mode (mode-permissions mode))
                  owner (resource 'user owner)
                  group (resource 'group group)
                  ensure :present)
            (return (values mode links owner group size mtime))))
      (properties* ensure mode links owner group size mtime))))
