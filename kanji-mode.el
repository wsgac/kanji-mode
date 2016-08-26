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

;;; Commentary: 

;; You can add a text-mode hook to enable kanji-mode automatically
;; every time you enter text-mode. To do so add the following to 
;; your .emacs file:
;; (add-hook 'text-mode-hook 'kanji-mode)

;;; Code:


;;;;;;;;;;;;;;;;;;;;;;;;;
;; Paths and variables ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar *kanji-svg-path* (concat (file-name-directory load-file-name) "kanji")
  "Relative path to stroke order files in SVG format.")
(make-variable-buffer-local '*kanji-svg-path*)

(defvar *km:kakasi-executable* (locate-file "kakasi" exec-path)
  "Path to Kakasi binary.")

(defvar *km:kakasi-common-options* "-iutf8 -outf8"
  "Kakasi command-line options common to all calls.")

;; Conversion options
(defvar *km:kanji->hiragana* "-JH"
  "Kakasi comman-line options for converting kanji to hiragana.")

(defvar *km:all->romaji* "-Ja -Ha -Ka -ka -Ea"
  "Kakasi comman-line options for converting Japanese to romaji.")

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

(defun km:char-to-hex (char)
  "Return hex code for character, padded with `0`s to conform with KanjiVG naming convention."
  (format "%05x" char))

(defun km:command->string (text conversion &optional exec common)
  "Run conversion command on TEXT using options specified in
   CONVERSION. Optionally provide your own Kakasi EXECutable and
   COMMON CLI options. Since Kakasi only accepts files as input,
   I'm using heredocs to make TEXT look like a file."
  (when (null exec) (setq exec *km:kakasi-executable*))
  (when (null common) (setq common *km:kakasi-common-options*))
  (unless (and *km:kakasi-executable*
	       (file-exists-p *km:kakasi-executable*)
	       (file-executable-p *km:kakasi-executable*))
    (error "You don't seem to have Kakasi installed."))
  (replace-regexp-in-string
   "\n$" "" (shell-command-to-string
	     (format "echo '%s' | %s %s %s" text exec common conversion))))

(defun km:kanji->hiragana (text)
  (km:command->string text *km:kanji->hiragana*))

(defun km:all->romaji (text)
  (km:command->string text *km:all->romaji*))

(defmacro km:interactive-function (fn)
  "Abstract common behavior for transcription functions. When
   called without a prefix argument, the function's result will
   be printed in the minibuffer. When called with prefix argument
   -1, it will place the results in the kill-ring instead. Any
   other prefix argument will produce a new buffer containing
   results of the transcription."
  `(let* ((text (if (= start end)
		    (thing-at-point 'word)
		  (buffer-substring start end)))
	  (transcribed (,fn text)))
    (cl-case current-prefix-arg
      ((nil)
       (message "%s" transcribed))
      ((-)
       (kill-new transcribed)
       (message "Transcription finished; pushed result to kill ring."))
      (t
       (with-current-buffer
	   (generate-new-buffer "kanji-mode transcription")
	 (insert transcribed)
	 (local-set-key (kbd "q") 'kill-this-buffer)
	 (switch-to-buffer (current-buffer))
	 (message "Press 'q' to kill this buffer."))))))

(defun kanji-mode-kanji-to-hiragana (start end)
  (interactive "r")
  (km:interactive-function km:kanji->hiragana))

(defun kanji-mode-all-to-romaji (start end)
  (interactive "r")
  (km:interactive-function km:all->romaji))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stroke order functions ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-svg-for-kanji-code (code)
  "Return an image object for the Unicode code provided."
  (let ((image-path (concat (expand-file-name code *kanji-svg-path*) ".svg")))
    (create-image image-path)))

(defun km:create-buffer-with-image (name)
  "Create new buffer with relevant image and switch to it.
Buffer can be closed by hitting `q`"
  (with-current-buffer (generate-new-buffer name)
    (let ((image (get-svg-for-kanji-code name)))
      (iimage-mode)
      (iimage-mode-buffer t)
      (insert-image image)
      (local-set-key (kbd "q") 'kill-this-buffer)
      (switch-to-buffer (current-buffer)))))

(defun kanji-mode-stroke-order (point)
  "Take character at point and try to display its stroke order."
  (interactive "d")
  (let ((char (char-after point)))
    (km:create-buffer-with-image (km:char-to-hex char))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minor mode definition ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(define-minor-mode kanji-mode
  "Minor mode for displaying Japanese characters' stroke orders."
  :lighter " kanji"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "M-s M-o") 'kanji-mode-stroke-order)
	    (define-key map (kbd "M-s M-h") 'kanji-mode-kanji-to-hiragana)
	    (define-key map (kbd "M-s M-r") 'kanji-mode-all-to-romaji)
	    map)
  )

(provide 'kanji-mode)

;;; kanji-mode.el ends here
