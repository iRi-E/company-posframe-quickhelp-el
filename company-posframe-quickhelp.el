;;; company-posframe-quickhelp.el --- Use company-quickhelp with company-posframe

;; Copyright (C) 2019 S. Irie

;; Author: S. Irie
;; Maintainer: S. Irie
;; URL: https://github.com/iRi-E/company-posframe-quickhelp-el
;; Version: 0.1.0
;; Keywords: abbrev, convenience, help
;; Package-Requires: ((emacs "26.0")(company "0.9.0")(posframe "0.1.0")(company-posframe "0.1.0")(company-quickhelp "2.2.0")(pos-tip "0.4.6"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This program allows us to use company-quickhelp with company-posframe.

;; Put the following code to your init.el:

;; (eval-after-load 'company-posframe
;;   '(require 'company-posframe-quickhelp))

;;; Code:
;; * company-posframe-quickhelp's code
(require 'company-posframe)
(require 'company-quickhelp)

(defun company-posframe-quickhelp--show ()
  "Analogue of `company-quickhelp--show', working with company-posframe."
  (when (company-quickhelp-pos-tip-available-p)
    (company-quickhelp--cancel-timer)
    (while-no-input
      (let* ((selected (nth company-selection company-candidates))
             (doc (let ((inhibit-message t))
                    (company-quickhelp--doc selected)))
             (width 80)
             (timeout 300)
             (posframe (let* ((buf (get-buffer company-posframe-buffer))
                              (frame (and buf (buffer-local-value 'posframe--frame buf))))
                         (and (frame-live-p frame) (frame-visible-p frame) frame)))
             (dx (and posframe
                      (- (frame-native-width posframe)
                         (* (frame-char-width)
                            (1+ (length (or company-common company-prefix)))))))
             (x-gtk-use-system-tooltips nil)
             (fg-bg `(,company-quickhelp-color-foreground
                      . ,company-quickhelp-color-background)))
        (when doc
          (with-no-warnings
            (if company-quickhelp-use-propertized-text
                (let* ((frame (window-frame (selected-window)))
                       (max-width (pos-tip-x-display-width frame))
                       (max-height (pos-tip-x-display-height frame))
                       (w-h (pos-tip-string-width-height doc)))
                  (cond
                   ((> (car w-h) width)
                    (setq doc (pos-tip-fill-string doc width nil 'none nil max-height)
                          w-h (pos-tip-string-width-height doc)))
                   ((or (> (car w-h) max-width)
                        (> (cdr w-h) max-height))
                    (setq doc (pos-tip-truncate-string doc max-width max-height)
                          w-h (pos-tip-string-width-height doc))))
                  (pos-tip-show-no-propertize doc fg-bg nil nil timeout
                                              (pos-tip-tooltip-width (car w-h) (frame-char-width frame))
                                              (pos-tip-tooltip-height (cdr w-h) (frame-char-height frame) frame)
                                              nil dx))
              (pos-tip-show doc fg-bg nil nil timeout width nil dx))))))))

(defun company-posframe-quickhelp-advice ()
  "Attach/detach advice to use quickhelp for company-posframe."
  (if company-posframe-mode
      (advice-add #'company-quickhelp--show
                  :override #'company-posframe-quickhelp--show)
    (advice-remove #'company-quickhelp--show
                   #'company-posframe-quickhelp--show)))

(company-posframe-quickhelp-advice)
(add-hook 'company-posframe-mode-hook #'company-posframe-quickhelp-advice)

(provide 'company-posframe-quickhelp)

;;; company-posframe-quickhelp.el ends here
