;; Skill Assessment Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data Variables
(define-data-var last-test-id uint u0)

;; Maps
(define-map skill-tests
  { test-id: uint }
  {
    skill: (string-ascii 64),
    questions: (list 20 (string-ascii 256)),
    answers: (list 20 (string-ascii 256))
  }
)

(define-map test-results
  { user: principal, test-id: uint }
  {
    score: uint,
    timestamp: uint
  }
)

;; Public Functions
(define-public (create-skill-test (skill (string-ascii 64)) (questions (list 20 (string-ascii 256))) (answers (list 20 (string-ascii 256))))
  (let
    (
      (new-test-id (+ (var-get last-test-id) u1))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? skill-tests { test-id: new-test-id })) err-already-exists)
    (map-set skill-tests
      { test-id: new-test-id }
      {
        skill: skill,
        questions: questions,
        answers: answers
      }
    )
    (var-set last-test-id new-test-id)
    (ok new-test-id)
  )
)

(define-public (submit-test-result (test-id uint) (score uint))
  (let
    (
      (test (unwrap! (map-get? skill-tests { test-id: test-id }) err-not-found))
    )
    (map-set test-results
      { user: tx-sender, test-id: test-id }
      {
        score: score,
        timestamp: block-height
      }
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-skill-test (test-id uint))
  (map-get? skill-tests { test-id: test-id })
)

(define-read-only (get-test-result (user principal) (test-id uint))
  (map-get? test-results { user: user, test-id: test-id })
)

