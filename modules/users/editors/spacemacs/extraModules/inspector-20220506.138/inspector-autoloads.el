;;; inspector-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "inspector" "inspector.el" (0 0 0 0))
;;; Generated autoloads from inspector.el

(autoload 'inspect-expression "inspector" "\
Evaluate and inspect EXP expression.

\(fn EXP)" t nil)

(autoload 'inspector-inspect "inspector" "\
Top-level function for inspecting OBJECTs.
When PRESERVE-HISTORY is T, inspector history is not cleared.

\(fn OBJECT &optional PRESERVE-HISTORY)" nil nil)

(autoload 'inspect-last-sexp "inspector" "\
Evaluate and inspect sexp before point." t nil)

(autoload 'debugger-inspect-locals "inspector" "\
Inspect local variables of the frame at point in debugger backtrace." t nil)

(autoload 'debugger-inspect-current-frame "inspector" "\
Inspect current frame in debugger backtrace." t nil)

(autoload 'debugger-inspect-frame-and-locals "inspector" "\
Inspect current frame and locals in debugger backtrace." t nil)

(register-definition-prefixes "inspector" '("inspector-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; inspector-autoloads.el ends here
