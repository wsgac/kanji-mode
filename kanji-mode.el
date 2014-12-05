;; Set up filesystem path containing kanji stroke order files in SVG format
(defvar *kanji-svg-path* (concat (file-name-directory load-file-name) "kanji"))

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
  (let ((image-path (concat (expand-file-name code *kanji-svg-path*) ".svg")))
    (create-image image-path)))

(defun create-buffer-with-image (name)
  (let ((buffer (generate-new-buffer name))
    	(image (get-svg-for-kanji-code name)))
    (switch-to-buffer buffer)
    (local-set-key (kbd "q") 'kill-this-buffer)
    (turn-on-iimage-mode)
    (iimage-mode-buffer t)
    (insert-image image)))

(defun stroke-order (point)
  (interactive "d")
  (let ((char (char-after point)))
    (create-buffer-with-image (char-to-hex char))))

(define-minor-mode kanji-mode
  "Minor mode for displaying Japanese characters' stroke orders."
  :lighter " kanji"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "M-s M-o") 'stroke-order)
	    map)
  (make-local-variable '*kanji-svg-path*)
  )

(add-hook 'text-mode-hook 'kanji-mode)

(provide 'kanji-mode)
