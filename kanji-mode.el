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
