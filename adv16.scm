;;; -*- mode: scheme -*-

(define signal '(5 9 7 9 6 3 3 2 4 3 0 2 8 0 5 2 8 2 1 1 0 6 0 6 5 7 5 7 7 0 3 9 7 4 4 0 5 6 6 0 9 6 3 6 5 0 5 1 1 1 3 1 3 3 3 6 0 9 4 8 6 5 9 0 0 6 3 5 3 4 3 6 8 2 2 9 6 7 0 2 0 9 4 0 1 8 4 3 2 7 6 5 6 1 3 0 1 9 3 7 1 2 3 4 4 8 3 8 1 8 4 1 5 9 3 4 9 1 4 5 7 5 7 1 7 1 3 4 6 1 7 7 8 3 5 1 5 2 3 7 3 0 0 9 1 9 2 0 1 9 8 9 7 0 6 4 5 1 5 2 4 0 6 9 0 4 4 9 2 1 3 8 4 7 3 8 9 3 0 1 7 2 0 2 6 2 3 4 8 7 2 5 2 5 2 5 4 6 8 9 6 0 9 7 8 7 7 5 2 4 0 1 3 4 2 6 8 7 0 9 8 9 1 8 8 0 4 2 1 0 4 9 4 3 9 1 1 6 1 5 3 1 0 0 8 3 4 1 3 2 9 0 1 6 6 2 6 9 2 2 9 9 0 9 3 8 8 5 4 6 8 1 5 7 5 3 1 7 5 5 9 8 2 1 0 6 7 9 3 3 0 5 8 6 3 0 6 8 8 3 6 5 0 6 7 7 9 0 8 1 2 3 4 1 4 7 5 1 6 8 2 0 0 2 1 5 4 9 4 9 6 3 6 9 0 5 9 3 8 7 3 2 5 0 8 8 4 8 0 7 8 4 0 6 1 1 4 8 7 2 8 8 5 6 0 2 9 1 7 4 8 4 1 4 1 6 0 5 5 1 5 0 8 9 7 9 3 7 4 3 3 5 2 6 7 1 0 6 4 1 4 6 0 2 5 2 6 2 4 9 4 0 1 2 8 1 0 6 6 5 0 1 6 7 7 2 1 2 0 0 2 9 8 0 6 1 6 7 1 1 0 5 8 8 0 3 8 4 5 3 3 6 0 6 7 1 2 3 2 9 8 9 8 3 2 5 8 0 1 0 0 7 9 1 7 8 1 1 1 6 7 8 6 7 8 7 9 6 5 8 6 1 7 6 7 0 5 1 3 0 9 3 8 1 3 9 3 3 7 6 0 3 5 3 8 6 8 3 8 0 3 1 5 4 8 2 4 5 0 2 7 6 1 2 2 8 1 8 4 2 0 9 4 7 3 3 4 4 6 0 7 0 5 5 9 2 6 1 2 0 8 2 9 7 5 1 5 3 2 8 8 7 8 1 0 4 8 7 1 6 4 4 8 2 3 0 7 5 6 4 7 1 2 6 9 2 2 0 8 1 5 7 1 1 8 9 2 3 5 0 2 0 1 0 0 2 8 2 5 0 8 8 6 2 9 0 8 7 3 9 9 5 5 7 7 1 0 2 1 7 8 5 2 6 9 4 2 1 5 2))

(define (generate-vector from to)
  "Generates a segment of the long signal as a vector"
  (let ((v (make-vector (- to from)))
        (len (length signal)))
    (let loop ((i 0) (j from))
      (if (< j to)
          (let ((index (modulo j len)))
            (vector-set! v i (list-ref signal index))
            (loop (+ i 1) (+ j 1)))
          v))))

(define (iterate! v n)
  "Performs (destructively) the FFT iteration on the V vector N times"
  (if (zero? n)
      v
      (let loop ((i (- (vector-length v) 1))
                 (acc 0))
        (if (< i 0)
            (iterate! v (- n 1))
            (let ((next (modulo (+ acc (vector-ref v i)) 10)))
              (vector-set! v i next)
              (loop (- i 1) next))))))

(define (take v n)
  "Takes the first N values of a vector"
  (let loop ((n (- n 1)) (lst '()))
    (if (< n 0)
        lst
        (loop (- n 1) (cons (vector-ref v n) lst)))))

(define (adv16b)
  (let ((v (generate-vector 5979633 6500000)))
    (iterate! v 100)
    (for-each display (take v 8))
    (newline)))
