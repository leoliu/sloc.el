;;; sloc.el --- source lines of code                 -*- lexical-binding: t; -*-

;; Copyright (C) 2013  Leo Liu

;; Author: Leo Liu <sdl.web@gmail.com>
;; Version: 1.0
;; Keywords: data, tools
;; Created: 2013-08-24

;; This program is free software; you can redistribute it and/or modify
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

;; Who cares?

;;; Code:

(require 'newcomment)                   ; for emacs < 24.3

(defun sloc-beginning-of-code ()
  "Move point to the beginning of code block after point."
  (forward-comment (point-max)))

(defun sloc-end-of-code (&optional bound)
  "Move point to the end of current code block."
  (comment-normalize-vars)
  (let ((bound (or bound (point-max))))
    (goto-char (or (comment-search-forward bound t) bound))))

(defun sloc-count-code-lines (beg end)
  (goto-char beg)
  (beginning-of-line)
  (let ((lines 0))
    (while (and (< (point) end) (not (eobp)))
      (unless (looking-at-p "^\\s-*$")
        (setq lines (1+ lines)))
      (forward-line 1))
    lines))

;;;###autoload
(defun sloc (beg end)
  "Get the sloc in the region BEG and END ignoring blank lines."
  (interactive
   (if (use-region-p)
       (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (save-excursion
    (let ((beg (min beg end))
          (end (max beg end))
          (code-lines 0))
      (goto-char beg)
      (while (and (< (point) end) (not (eobp)))
        (setq code-lines (+ code-lines
                            (sloc-count-code-lines (progn
                                                     (sloc-beginning-of-code)
                                                     (point))
                                                   (progn
                                                     (sloc-end-of-code end)
                                                     (point))))))
      (when (called-interactively-p 'interactive)
        (message "%d sloc" code-lines))
      code-lines)))

(provide 'sloc)
;;; sloc.el ends here
