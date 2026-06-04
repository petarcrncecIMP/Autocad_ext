(vl-load-com)
(setvar "LISPINIT" 0)

(defun imp-run-startup (/ product addin-root imp-folder r-major acad-year mg m r)
  (setq product (getvar 'PRODUCT))

  ; Each addin owns its own root under %APPDATA%\IMP_Tools\<addin>\.
  ; Resources (Tools.cuix, Project.dvb) live at addin-root, year-specific
  ; DLLs at addin-root\<year>\.
  (setq r-major (atoi (substr (getvar "ACADVER") 1 2)))
  (setq acad-year (itoa (+ 2000 r-major)))

  (if (equal product "GstarCAD")
    (progn
      (setq addin-root (strcat (getenv "APPDATA") "\\IMP_Tools\\GStar\\"))
      (setq imp-folder (strcat addin-root acad-year "\\"))
      (setq mg (vla-get-menugroups (vlax-get-acad-object)))
      (setq m "Tools")
      (if (/= 'vla-object (type (setq r (vl-catch-all-apply 'vla-item (list mg m)))))
        (command "_.menuload" (strcat addin-root m ".cuix")))
      (command "netload" (strcat imp-folder "GStar_Project.dll")))
    (progn
      (setq addin-root (strcat (getenv "APPDATA") "\\IMP_Tools\\Plant3D\\"))
      (setq imp-folder (strcat addin-root acad-year "\\"))
      (command "netload" (strcat imp-folder "MacroUpdater.dll"))
      (command "updateMacros")))
  (vl-vbarun (strcat addin-root "Project.dvb!onStartup"))
  (princ))

(defun S::STARTUP ()
  (if (not *imp-ran*)
    (progn
      (setq *imp-ran* T)
      (imp-run-startup))
    (command "toolsStartup")))
