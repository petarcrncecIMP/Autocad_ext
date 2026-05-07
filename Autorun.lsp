(vl-load-com)
(setvar "LISPINIT" 0)

(defun imp-run-startup (/ product imp-root imp-folder r-major acad-year mg m r)
  (setq product (getvar 'PRODUCT))
  (setq imp-root (strcat (getenv "APPDATA") "\\IMP_Tools\\"))

  ; AutoCAD R-version → year. Each addin has its own folder under
  ; IMP_Tools\<addin>\<year>\ so addins/years don't step on each other.
  (setq r-major (atoi (substr (getvar "ACADVER") 1 2)))
  (setq acad-year (itoa (+ 2000 r-major)))

  (if (equal product "GstarCAD")
    (progn
      (setq imp-folder (strcat imp-root "GStar\\" acad-year "\\"))
      (setq mg (vla-get-menugroups (vlax-get-acad-object)))
      (setq m "Tools")
      (if (/= 'vla-object (type (setq r (vl-catch-all-apply 'vla-item (list mg m)))))
        (command "_.menuload" (strcat imp-root m ".cuix")))
      (command "netload" (strcat imp-folder "GStar_Project.dll")))
    (progn
      (setq imp-folder (strcat imp-root "Plant3D\\" acad-year "\\"))
      (command "netload" (strcat imp-folder "MacroUpdater.dll"))
      (command "updateMacros")))
  (vl-vbarun (strcat imp-root "Project.dvb!onStartup"))
  (princ))

(defun S::STARTUP ()
  (if (not *imp-ran*)
    (progn
      (setq *imp-ran* T)
      (imp-run-startup))
    (command "toolsStartup")))
