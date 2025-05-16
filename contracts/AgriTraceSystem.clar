;; AgriTraceSystem - Agricultural product traceability
(define-map crops uint {
  farmer: principal,
  crop-name: (string-utf8 64),
  cultivation-methods: (string-utf8 256),
  harvest-date: uint,
  farm-location: (string-utf8 64),
  certified: bool
})

(define-map farmer-crops principal (list 100 uint))
(define-map certifiers principal bool)
(define-data-var crop-id-nonce uint u0)

;; Error codes
(define-constant err-not-farmer (err u100))
(define-constant err-not-certifier (err u101))
(define-constant err-crop-not-found (err u102))
(define-constant err-not-authorized (err u403))
(define-constant err-too-many-crops (err u104))
(define-constant err-invalid-principal (err u105))
(define-constant err-invalid-crop-name (err u106))
(define-constant err-invalid-methods (err u107))
(define-constant err-invalid-date (err u108))
(define-constant err-invalid-location (err u109))
(define-constant err-invalid-crop-id (err u110))

;; Contract owner for admin functions
(define-constant contract-owner tx-sender)

;; Add a certifier
(define-public (add-certifier (certifier principal))
  (begin
    ;; Check if sender is contract owner
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    
    ;; Validate certifier principal
    (asserts! (not (is-eq certifier 'SP000000000000000000002Q6VF78)) err-invalid-principal)
    
    ;; Add certifier to map
    (ok (map-set certifiers certifier true))
  )
)

;; Register a new crop
(define-public (register-crop 
  (crop-name (string-utf8 64)) 
  (cultivation-methods (string-utf8 256)) 
  (harvest-date uint) 
  (farm-location (string-utf8 64)))
  (let
    ((crop-id (var-get crop-id-nonce))
     (farmer tx-sender)
     (farmer-current-crops (default-to (list) (map-get? farmer-crops farmer))))
    
    ;; Validate inputs
    (asserts! (> (len crop-name) u0) err-invalid-crop-name)
    (asserts! (> (len cultivation-methods) u0) err-invalid-methods)
    (asserts! (> harvest-date u0) err-invalid-date)
    (asserts! (> (len farm-location) u0) err-invalid-location)
    
    ;; Check if farmer has reached crop limit
    (asserts! (< (len farmer-current-crops) u100) err-too-many-crops)
    
    ;; Store the crop data
    (map-set crops crop-id {
      farmer: farmer,
      crop-name: crop-name,
      cultivation-methods: cultivation-methods,
      harvest-date: harvest-date,
      farm-location: farm-location,
      certified: false
    })
    
    ;; Create a new list with the crop ID
    (let 
      ((new-crop-list (unwrap-panic (as-max-len? (concat (list crop-id) farmer-current-crops) u100))))
      ;; Update farmer's crop list
      (map-set farmer-crops farmer new-crop-list)
    )
    
    ;; Increment the crop ID counter
    (var-set crop-id-nonce (+ crop-id u1))
    
    (ok crop-id)))

;; Certify a crop
(define-public (certify-crop (crop-id uint))
  (begin
    ;; Validate crop ID
    (asserts! (< crop-id (var-get crop-id-nonce)) err-invalid-crop-id)
    
    (let
      ((crop (unwrap! (map-get? crops crop-id) err-crop-not-found)))
      
      ;; Check if sender is a certifier
      (asserts! (default-to false (map-get? certifiers tx-sender)) err-not-certifier)
      
      ;; Update crop certification status
      (ok (map-set crops crop-id (merge crop {certified: true})))
    )
  )
)

;; Get crop details
(define-read-only (get-crop (crop-id uint))
  (map-get? crops crop-id))

;; Get farmer's crops
(define-read-only (get-farmer-crops (farmer principal))
  (default-to (list) (map-get? farmer-crops farmer)))

;; Check if principal is a certifier
(define-read-only (is-certifier (address principal))
  (default-to false (map-get? certifiers address)))