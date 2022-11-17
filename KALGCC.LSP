;;; Kalah.lisp-- final version
;;  4 player types 
;;         
;;Copyright (c) 1998 Catalin Loghin 1251 E

;;; How many stones are in each hole at the beginning of the game.
(defvar *initial-stones-per-hole* 6) 

;;;  How many plies should be searched ?
(defvar *ply-no* 3)

;;; Which is the total no of stones?
(defvar *total* (* 12 *initial-stones-per-hole*))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; We'll store the Kalah board as an array like this
;;;   12 11 10  9  8  7
;;; 13                  6
;;;    0  1  2  3  4  5
;;; Player 1 has the bottom (holes 0-5, kalah=6) 
;;; while Player 2 has the top (7-12, kalah=13)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: find-opposing-holes
;;; Purpose:  Given a hole on the board, find the hole that is
;;;           opposite of it.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun find-opposing-hole (which-hole)
(let ((*opposing-holes* '((0 . 12) (1 . 11) (2 . 10) (3 . 9)  (4 . 8)  (5 . 7)
  (6 . 13) (7 . 5) (8 . 4) (9 . 3) (10 . 2) (11 . 1) (12 . 0) (13 . 6) ) ))
   (check-valid-hole which-hole)
    (cdr (assoc which-hole *opposing-holes*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Purpose: Keep the structure of the board
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defstruct board
  (holes))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: printboard
;;; Purpose : This prints a board, in a neat way.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun printboard ( board )
 (kalah-format t "~&   ")
 (do ((x 12 (- x 1)))  ;; print the first upper row of elements 
      ((= x 6))
  (kalah-format t "~A " (aref (board-holes board) x)))
  (kalah-format t "~%~S                   ~S~%"
   (aref (board-holes board) 13) (aref (board-holes board) 6)) ; prints kalahs
    (kalah-format t "   ")
     (dotimes (x 6)        ;; print the second lower row of elements 
    (kalah-format t "~A " (aref (board-holes board) x))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: new-board
;;; Purpose:  this creates a new board, and initializes the holes
;;;           to 0.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun new-board ()
  (let ((b (make-board)))
    (setf (board-holes b)
          (make-array 14
                      :element-type 'integer
                      :initial-element 0))
      b))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: co-board
;;; Purpose:  This makes a copy of the board.
;;; avoid standard struct  function copy-board
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun co-board (b)
  (let ((new-board (new-board)))
    (dotimes (hole 14)
      (setf (aref (board-holes new-board) hole)
            (aref (board-holes b) hole)))
    new-board))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: check-valid-hole
;;; Purpose:  This checks if the hole number is a valid hole
;;;           for a kalah board and reports a nasty error if it
;;;           isn't.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun check-valid-hole (hole-number)
  (if (or (not (integerp hole-number))
          (< hole-number 0)
          (> hole-number 13))
      (error "Invalid hole! (~S)~%" hole-number)
      (values)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: check-valid-hole-for-move
;;; Purpose:  This checks if the hole number is a valid hole
;;;           for a kalah board move and reports a nasty error if
;;;           it isn't.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun check-valid-hole-for-move (hole-number)
  (if (or (not (integerp hole-number))
          (< hole-number 0)  ;; out of range
          (> hole-number 13) ;; out of range
          (= hole-number 6)  ;; Player 1's kalah
          (= hole-number 13));; Player 2's kalah
      (error "Invalid hole for move! (~S)~%" hole-number)
      (values)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: board-accessors
;;; Purpose:  This help access holes in a board.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun get-stone-count (board hole)
  (check-valid-hole hole)
  (aref (board-holes board) hole))

(defun set-stone-count! (board hole count)
  (check-valid-hole hole)
  (setf (aref (board-holes board) hole)
        count)
  count)

(defun increment-stone-count! (board hole)
  (check-valid-hole hole)
  (let ((count (aref (board-holes board) hole)))
  (setf (aref (board-holes board) hole)
        (+ 1 count))
  (+ 1 count)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: evaluation of the board position  
;;; Purpose: determine the value of the position 
;;;          it was considered to be the difference between the kalahs
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun evaluation (board player )
 (let ( ( kalah6    (get-stone-count board 6))
          ( kalah13  (get-stone-count board 13)))
 (if (= player 1)  (- kalah6 kalah13)
                            (- kalah13 kalah6))
      ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: make-initial-board
;;; Purpose:  This makes a starting board for a game of Kalah.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun make-initial-board 
         (&optional (*initial-stones-per-hole* *initial-stones-per-hole*))
  (let ((b (new-board)))
    (dotimes (hole 14)
      (if (and (not (= hole 6))
               (not (= hole 13)))
          (set-stone-count! b hole *initial-stones-per-hole*)
          (set-stone-count! b hole 0)))
    b))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: make-board-move
;;; Purpose:  Given a board, this distributes the stones out from the
;;;           given hole and moves them around the board. A NEW!
;;;           board is returned. If the move couldn't be made,
;;;           nil is returned.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun make-board-move (b hole)
  (check-valid-hole-for-move hole)
  (if (= 0 (get-stone-count b hole))
      nil ;; no next move
      (let ((b (co-board b)))
        (let* ((our-kalah (if (< hole 6) 6 13))
               (other-kalah (find-opposing-hole our-kalah))
               (num-stones (get-stone-count b hole)))
          (set-stone-count! b hole 0)
          ;;; Move all the stones around the board, skipping the other's kalah
          (let ((last-hole
                 (do ((x (+ hole 1) (+ x 1))
                      (final-hole hole)
                      (count 0))
                     ((= count num-stones) final-hole)
                   (let ((hole-to-fill (mod x 14)))
                     (when (not (= hole-to-fill other-kalah))
                       (increment-stone-count! b hole-to-fill)
                       (setf count (+ 1 count))
                       ;; Check if this is the last stone, and we landed in an
                       ;; empty hole (not our kalah) on our side.
                       (when (= count num-stones) ;; made last move
                         (setf final-hole hole-to-fill)))))))
            (when (and (not (= last-hole our-kalah))       ;; not our kalah
                       (= 1 (get-stone-count b last-hole)) ;; hole was empty
                       (hole-on-same-side hole last-hole) ;; ended on our side
                (< 0 (get-stone-count b (find-opposing-hole last-hole ))))    
                    ;;; A Capture was made. Adjust the board
              (let ((count1 (get-stone-count b last-hole))
                   (count2 (get-stone-count b (find-opposing-hole last-hole)))
)
                (set-stone-count! b our-kalah (+ (get-stone-count b our-kalah)
                                                 count1 count2))
                (set-stone-count! b last-hole 0)
                (set-stone-count! b (find-opposing-hole last-hole) 0)))
            (if (= (mod last-hole 14) our-kalah)
                (values b T)
                (values b NIL)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: hole-on-same-side
;;; Purpose:  This returns T if the two holes are on the same
;;;           side of the board, NIL otherwise. If a hole
;;;           is a Kalah, NIL will be returned.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun hole-on-same-side (hole1 hole2)
  (and (not (= hole1 13))
       (not (= hole2 13))
       (or (and (> hole1 6)
                (> hole2 6))
           (and (< hole1 6)
                (< hole2 6)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Purpose: keep a structure with moves made ,situation of game
;;;          and the final board. A list is necessary rather than
;;;          a simple index of move because the move may be 
;;;          continued.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defstruct move
  moves            ;; a list of the moves made
  ended-game       ;; boolean--is the game over after this move?
  final-board)     ;; the final board position after the moves were made.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: make-next-boards
;;; Purpose:  makes a list of the next boards that a player
;;;           can come up with. If a move allows a player to
;;;           move again, that board isn't given, but the
;;;           following boards are. That's why we return
;;;           the move structure.
;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun make-next-boards (b player)
;  (assert  (or (= player 2) (= player 1)))
  (do ( (i (if (= player 1) 0 7) (+ i 1) )
          (moves '() )   )
    ( (or (= i 6) (= i 13))     moves )
        (multiple-value-bind (next-board still-our-turn)
                             (make-board-move b i)
          (cond (still-our-turn ;; we landed in the kalah
                 (if (= 0 (count-players-stones next-board player))
                     ;; We ended the game, so can't make more moves.
                     (let ((move (make-move :moves (list i)
                                            :ended-game T
                                            :final-board next-board)))
                     (setf moves   (append moves (list move))))
                     ;; Continue making moves
                     (let ((next-moves (make-next-boards next-board player)))
                       (dolist (move next-moves)
                         (setf (move-moves move) (cons i (move-moves move))))
                          (setf moves  (append moves next-moves)))))
                (next-board     ;; made a move that ended our turn.
                 (let ((move (make-move :moves (list i)
                                        :ended-game NIL
                                        :final-board next-board)))
                                  (setf moves (append moves (list move)))))
                (T              ;; couldn't make a move
                                     moves)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: play-kalah
;;; Purpose:  This will play a game of kalah. It needs to be
;;;           called with two functions, to do the actual
;;;           playing. The functions take a board and a player
;;;           number and return a board. It's up to them to print
;;;           out the current board and the result of any moves
;;;           that they make. User-player and stupid-player
;;;           are examples.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun play-kalah (player1-function player2-function 
            &optional (*initial-stones-per-hole* *initial-stones-per-hole*))
  (let ((board (make-initial-board)))
    (play-kalah-helper board player1-function player2-function 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: play-kalah-helper
;;; Purpose:  Administrative Assistant to play-kalah
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun play-kalah-helper 
               (board player1-function player2-function current-player)

  (let ((stone-count (count-players-stones board current-player)))
    (if (= stone-count 0)
        (do-end-game board current-player)
        (let ((player-function (if (= current-player 1)
                                   player1-function
                                   player2-function)))
          (multiple-value-bind (next-board player-ended-in-kalah)
                               (funcall player-function board current-player)
           ; (if player-ended-in-kalah
           ;     (assert (= (count-players-stones next-board current-player) 0))
           ;    )
            (cond (player-ended-in-kalah
                   (do-end-game next-board current-player))
                  (T
                   (play-kalah-helper next-board
                                      player1-function player2-function
                                      (if (= current-player 1) 2 1)))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun do-end-game (final-board final-player)
  (format t "~&~%Player ~S ended the game.~%" final-player)
  (let (kalah1 kalah2) 
             (if (= final-player 1) (prog2 (setf kalah1 (get-stone-count final-board 6))
                                                          (setf kalah2 (- *total* kalah1 )) )
                                              (prog2 (setf kalah2 (get-stone-count final-board 13))
                                                          (setf kalah1 (- *total*  kalah2 ))))
    (if (> kalah1 kalah2)
        (format t "Player 1 won with ~S stones to ~S stones."
               kalah1 kalah2)
        (if (< kalah1 kalah2)
              (format t "Player 2 won with ~S stones to ~S stones."
                kalah2 kalah1)
              (format t "The game is a draw with ~S stones to ~S stones."
                kalah2 kalah1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: player-has-caused-finish
;;; Purpose:  Assuming the given player has just made a move,
;;;           is the game over?
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun player-has-caused-finish (board player)
  (let ((num-stones (count-players-stones board player)))
    (if (= num-stones 0)
        T
        NIL)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: count-players-stones
;;; Purpose:  This counts how many stones a player has on his
;;;           side.
;;;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun count-players-stones (board player)
  (do (   (i  (if (= player 1) 0 7)  (+ i 1) ) 
             (sum 0 (+ sum (get-stone-count board i)))  )
    ( (or (= i 6) (= i 13))  sum ))   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: user-player
;;; Purpose:  This function performs a user-input play 
;;;           it can be used for none, one or two of the players    
;;; Returns values: (next-board player-ended-in-kalah)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun user-player (board player-number)
   (kalah-format t "~&The current board is: ~%" )
   (printboard board)
  (kalah-format t "~%You are player ~S~%" player-number)
  (kalah-format t "Enter your move ")
  (if (= player-number 1)
      (kalah-format t "(0 - 5)~%")
      (kalah-format t "(7 - 12)~%"))
  (let ((hole (get-move player-number)))
    (multiple-value-bind (next-board still-our-turn)
                         (make-board-move board hole)
      (cond (still-our-turn
             (if (> (count-players-stones next-board player-number) 0)
                 (user-player next-board player-number)
                 (values next-board T)))
            (next-board
             (values next-board NIL))
            (T
             (user-player board player-number))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: get-move
;;; Purpose:  This function asks the user for input
;;;           it shows an error message if the move is
;;;           illegal and prompts for another try  
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun get-move (player-number)
  (kalah-format t "=> ")
  (let ((num (read)))
    (cond ((or (not (integerp num))
               (and (= player-number 1)
                    (or (< num 0)
                        (> num 5)))
               (and (= player-number 2)
                    (or (< num 7)
                        (> num 12))))
           (kalah-format t "~&Bad Move! Try again.~%")
           (get-move player-number))
          (T num))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Find the best move, for PLAYER, according to EVAL-FN,
;;; searching PLY levels deep and backing up values
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun minimax (player board ply eval-fn)
  (if (= ply 0)
      (funcall eval-fn board player)
      (let ((moves (make-next-boards board player)))
        (if (null moves)
            (if (make-next-boards board (if (= player 1) 2 1) )
                (-   (minimax (if (= player 1) 2 1) board (- ply 1) eval-fn))
                (funcall eval-fn board player ))
            (let ((best-move nil)
                    (best-val nil))
              (dolist (move moves)
                (let* ((val (- (minimax (if (= player 1) 2 1) 
                     (move-final-board move) (- ply 1) eval-fn))))
                  (when (or (null best-val)
                            (> val best-val))
                    (setf best-val val)
                    (setf best-move move))))
              (values best-val best-move))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Find the best move, for PLAYER, according to EVAL-FN,
;;;  searching PLY levels deep and backing up values,
;;;  using cutoffs whenever possible."
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun alpha-beta (player board achievable cutoff ply eval-fn)
  (if (= ply 0)
      (funcall eval-fn  board player)
      (let ((moves  (make-next-boards board player)))
        (if (null moves)
            (if (make-next-boards board (if (= player 1) 2 1) )
                (- (alpha-beta (if (= player 1) 2 1) board
                               (- cutoff) (- achievable)
                               (- ply 1) eval-fn))
                (funcall eval-fn board player ))
            (let ((best-move (first moves)))
              (loop for move in moves do
      (let* ((val (- (alpha-beta (if (= player 1) 2 1) (move-final-board move)
                                 (- cutoff) (- achievable)
                                 (- ply 1) eval-fn))))
                  (when (> val achievable)
                    (setf achievable val)
                    (setf best-move move)))
                until (>= achievable cutoff))
              (values achievable best-move))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: master-player
;;; Purpose:  This function performs a computer-search move
;;;                   using minimax searching technique with alpha-beta 
;;;                     prunning where possible 
;;;                   losing value is considered -36 (stone no. /2)
;;;                   and winning value is chosen 36 (stone no. /2)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun master-player (board player)
  (multiple-value-bind (best-value best-move)
        (alpha-beta player board -36 36 (+ 1 *ply-no*)  'evaluation)
           (print-move board best-move player "Master-player")
      (values (move-final-board best-move)
              (move-ended-game best-move))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: smart-player
;;; Purpose:  This function performs a computer-search move
;;;                   using minimax searching technique
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun smart-player (board player)
  (multiple-value-bind (best-value best-move)
         (minimax player board *ply-no* 'evaluation)
           (print-move board best-move player "Smart-player")
      (values (move-final-board best-move)
              (move-ended-game best-move))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: stupid-player
;;; Purpose:  This function performs a computer-input play 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun stupid-player (board player-number)
  (let ((moves (make-next-boards board player-number)))
    (setf moves (sort moves #'(lambda (move1 move2)
                                (if (> (length (move-moves move1))
                                       (length (move-moves move2)))
                                    T
                                    NIL))))
    (let ((our-move (first moves)))
      (print-move board our-move player-number "Stupid-player")
      (values (move-final-board our-move)
              (move-ended-game our-move)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Function: print-move
;;; Purpose:  This function performs the interface for the play 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun print-move (board move player-number player-name)
  (let ((b (co-board board)))
    (kalah-format t "~&~A (player ~S) starts at board: ~%" player-name player-number )
    (printboard b)
    (dolist (hole (move-moves move))
      (setf b (make-board-move b hole))
      (kalah-format t "~%~A (player ~S) makes move: ~S, resulting:~%"
              player-name player-number hole )
      (printboard b))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Function: kalah-format
;;; Purpose:  Auxiliary used function
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun kalah-format (&rest args)
        (apply #'format args))

