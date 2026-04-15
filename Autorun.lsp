(vl-load-com)

(defun imp-run-startup (/ product imp-root imp-folder r-major acad-year mg m r)
  (setq product (getvar 'PRODUCT))
  (setq imp-root (strcat (getenv "APPDATA") "\\IMP_Tools\\"))

  ; Map AutoCAD R-version to year folder: R24.x=2024, R25.x=2025, etc.
  (setq r-major (atoi (substr (getvar "ACADVER") 1 2)))
  (setq acad-year (itoa (+ 2000 r-major)))
  (setq imp-folder (strcat imp-root acad-year "\\"))

  (if (equal product "GstarCAD")
    (progn
      (setq mg (vla-get-menugroups (vlax-get-acad-object)))
      (setq m "Tools")
      (if (/= 'vla-object (type (setq r (vl-catch-all-apply 'vla-item (list mg m)))))
        (command "_.menuload" (strcat imp-root m ".cuix")))
      (command "netload" (strcat imp-folder "GStar_Project.dll")))
    (progn
      (command "netload" (strcat imp-folder "MacroUpdater.dll"))
      (command "updateMacros")))
  (vl-vbarun (strcat imp-root "Project.dvb!onStartup"))
  (princ))

(defun S::STARTUP ()
  (imp-run-startup))
