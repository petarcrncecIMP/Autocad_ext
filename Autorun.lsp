(vl-load-com)
(setvar "LISPINIT" 0)

; The newest year folder under root that actually holds dll, or nil.
;
; Years are tried newest first rather than derived from ACADVER. GstarCAD
; reports an AutoCAD-compatible ACADVER - 2025 says 23.x - so 2000 + r-major
; resolved to \GStar\2023\ on a 2025 machine and NETLOAD threw
; "Dll was not found" at every startup.
(defun imp-find-dll (root dll / years y found)
  (setq years '("2030" "2029" "2028" "2027" "2026" "2025" "2024" "2023"))
  (foreach y years
    (if (and (not found) (findfile (strcat root y "\\" dll)))
      (setq found (strcat root y "\\" dll))))
  found)

(defun imp-run-startup (/ product addin-root imp-folder r-major acad-year mg m r dll)
  (setq product (getvar 'PRODUCT))

  ; Each addin owns its own root under %APPDATA%\IMP_Tools\<addin>\.
  ; Resources (Tools.cuix) live at addin-root, year-specific
  ; DLLs at addin-root\<year>\.
  (setq r-major (atoi (substr (getvar "ACADVER") 1 2)))
  (setq acad-year (itoa (+ 2000 r-major)))

  (if (equal product "GstarCAD")
    (progn
      (setq addin-root (strcat (getenv "APPDATA") "\\IMP_Tools\\GStar\\"))
      (setq mg (vla-get-menugroups (vlax-get-acad-object)))
      (setq m "Tools")
      (if (/= 'vla-object (type (setq r (vl-catch-all-apply 'vla-item (list mg m)))))
        (command "_.menuload" (strcat addin-root m ".cuix")))
      ; Said plainly rather than thrown: a missing DLL means an install that
      ; did not finish, and the exception named no folder.
      (setq dll (imp-find-dll addin-root "GStar_Project.dll"))
      (if dll
        (command "netload" dll)
        (princ (strcat "\nIMP: GStar_Project.dll not found under " addin-root))))
    (progn
      (setq addin-root (strcat (getenv "APPDATA") "\\IMP_Tools\\Plant3D\\"))
      (setq imp-folder (strcat addin-root acad-year "\\"))
      (setq dll (strcat imp-folder "MacroUpdater.dll"))
      (if (findfile dll)
        (progn
          (command "netload" dll)
          (command "updateMacros"))
        (princ (strcat "\nIMP: MacroUpdater.dll not found at " dll)))))
  (princ))

(defun S::STARTUP ()
  (if (not *imp-ran*)
    (progn
      (setq *imp-ran* T)
      (imp-run-startup))
    (command "toolsStartup")))
