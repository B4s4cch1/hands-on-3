(defrule r1 (hecho a) => (assert (hecho b)))
(defrule r2 (hecho b) => (assert (hecho c)))
(defrule r3 (hecho c) => (assert (hecho d)))
(defrule r4 (hecho d) => (assert (hecho e)))

;; initialize working mem
(reset)

;;Tell fact a
(assert (hecho a))

;;Call the inference engine
(run)
