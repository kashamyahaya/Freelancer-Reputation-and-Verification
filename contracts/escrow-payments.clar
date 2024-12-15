;; Escrow Payments Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var last-escrow-id uint u0)

;; Maps
(define-map escrows
  { escrow-id: uint }
  {
    client: principal,
    freelancer: principal,
    amount: uint,
    completed: bool
  }
)

;; Public Functions
(define-public (create-escrow (freelancer principal) (amount uint))
  (let
    (
      (new-escrow-id (+ (var-get last-escrow-id) u1))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set escrows
      { escrow-id: new-escrow-id }
      {
        client: tx-sender,
        freelancer: freelancer,
        amount: amount,
        completed: false
      }
    )
    (var-set last-escrow-id new-escrow-id)
    (ok new-escrow-id)
  )
)

(define-public (complete-escrow (escrow-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrows { escrow-id: escrow-id }) err-not-found))
    )
    (asserts! (is-eq (get client escrow) tx-sender) err-unauthorized)
    (asserts! (not (get completed escrow)) err-unauthorized)
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get freelancer escrow))))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { completed: true })
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

