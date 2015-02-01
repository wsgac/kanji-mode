;;; kanji-mode.el --- View stroke order for kanji characters at cursor

;; Copyright 2014-2015 Wojciech Gac

;; Author: Wojciech Gac <wojciech.s.gac@gmail.com>
;; URL: http://github.com/wsgac/kanji-mode 
;; Version: 1.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Code:

;;;;;;;;;;;
;; Paths ;;
;;;;;;;;;;;
(defvar *kanji-svg-path* (concat (file-name-directory load-file-name) "kanji")
  "Relative path to stroke order files in SVG format.")

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility functions ;;
;;;;;;;;;;;;;;;;;;;;;;;
(defun char-to-hex (char)
  "Return hex code for character, padded with `0`s to conform with KanjiVG naming convention."
  (format "%05x" char))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stroke order functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun get-svg-for-kanji-code (code)
  "Return an image object for the Unicode code provided."
  (let ((image-path (concat (expand-file-name code *kanji-svg-path*) ".svg")))
    (create-image image-path)))

(defun create-buffer-with-image (name)
  "Create new buffer with relevant image and switch to it.
Buffer can be closed by hitting `q`"
  (with-current-buffer (generate-new-buffer name)
    (let ((image (get-svg-for-kanji-code name)))
      (turn-on-iimage-mode)
      (iimage-mode-buffer t)
      (insert-image image)
      (local-set-key (kbd "q") 'kill-this-buffer)
      (switch-to-buffer (current-buffer)))))

(defun stroke-order (point)
  "Take character at point and try to display its stroke order."
  (interactive "d")
  (let ((char (char-after point)))
    (create-buffer-with-image (char-to-hex char))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor mode definition ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-minor-mode kanji-mode
  "Minor mode for displaying Japanese characters' stroke orders."
  :lighter " kanji"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "M-s M-o") 'stroke-order)
	    map)
  (make-local-variable '*kanji-svg-path*)
  )

;; Start mode automatically with `text-mode`
(add-hook 'text-mode-hook 'kanji-mode)

(provide 'kanji-mode)

;;; kanji-mode.el ends here
