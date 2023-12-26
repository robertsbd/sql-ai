;; this code has been created to use a sql-lite database. This could be changed to reflect the database that you are using

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; PACKAGES ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-ai
  :ensure t
  :commands (org-ai-global-mode)
  :config
  (setq org-ai-default-chat-model "gpt-3.5-turbo"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; CONSTANTS ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; if you are using a different database then modify this text to reflect the structure of that database. One could create this representation as the result of a database query to make this code more useful.
(setq db-prompt-pre-context "Given tables [Products] with following columns
           [ProductID],
           [ProductName],
           [SupplierID],
           [CategoryID],
           [QuantityPerUnit],
           [UnitPrice],
           [UnitsInStock],
           [UnitsOnOrder],
           [ReorderLevel],
           [Discontinued]
        Table [Categories] with the following columns
           [CategoryID],
           [CategoryName],
           [Description],
           [Picture]
        Table [Orders] with the following columns
           [OrderID],
           [CustomerID],
           [EmployeeID],
           [OrderDate],
           [RequiredDate],
           [ShippedDate],
           [ShipVia],
           [Freight],
           [ShipName],
           [ShipAddress],
           [ShipCity],
           [ShipRegion],
           [ShipPostalCode],
           [ShipCountry]
        Table [Order Details] with the following columns
           [OrderID],
           [ProductID],
           [UnitPrice],p
           [Quantity],
           [Discount]
        Write a SQLite query for the following question: "
      ai-output-buffer "sql-qry-and-output"
;;    my-db "ADD_DATABASE HERE"
;;    org-ai-openai-api-token "ADD_USER_TOKEN_HERE"
      db-prompt-post-context ". Don't include any explanations in your response.")

;; Enable modes that we require
(org-ai-global-mode 1)

(defun setup-output-buffer (buffer-name)
  "Create the output buffer we will be writing to, if it already exists then kill and create a new one to delete any exiting informat"
  (if (get-buffer buffer-name) (kill-buffer buffer-name))
  (get-buffer-create buffer-name))

(defun read-from-buffer-and-clear (buffer-name)
  "Read the contents of a buffer and return this as a string, then clear the buffer"
  (let
      ((str-output (with-current-buffer buffer-name (buffer-string))))
    (setup-output-buffer buffer-name)
    str-output))

(defun get-natural-language-prompt (x)
  "Get a natural language prompt from the user"
  (interactive "sWhat would you like to query in the database: ")
  x)

(defun openai-sql-query (prompt output-buffer-name)
  "Generate a SQL query from the prompt and clear the buffer it is read from"
  (org-ai-prompt prompt :output-buffer output-buffer-name)
  (sit-for 5)
  (read-from-buffer-and-clear output-buffer-name))

(defun db-run-sql-query (sql-qry db)
  "Read the sql from a string and return the output"
  (sqlite-execute (sqlite-open db) sql-qry))

(defun main (pre-prompt post-prompt db output-buffer)
  (setup-output-buffer output-buffer)
  (let*
      ((user-question (call-interactively 'get-natural-language-prompt))         ;; get user prompt
       (ai-prompt (concat pre-prompt user-question post-prompt))                 ;; create the total prompt to send to AI
       (sql-qry (openai-sql-query ai-prompt output-buffer))                      ;; generate AI SQL in buffer
       (sql-qry-output (db-run-sql-query sql-qry db)))                           ;; run SQL in the target db
    (with-current-buffer output-buffer                                           ;; wrte structured output to buffer
      (insert (concat "--------------\nUser query\n--------------\n\n"
		      user-question "\n\n"
		      "--------------\nAI Generated SQL\n--------------\n\n"
		      sql-qry "\n\n"
		      "--------------\nOutput from database\n--------------\n\n"
		      (mapconcat (lambda (x) (concat (format "%s" x) "\n")) sql-qry-output) "\n\n")))))

;;;; Run-program ;;;;

(main db-prompt-pre-context db-prompt-post-context my-db ai-output-buffer)

