# Enable tuple comparison for keyset pagination globally.
Pagy::OPTIONS[:tuple_comparison] = true
Pagy::OPTIONS[:client_max_limit] = 100
Pagy::OPTIONS[:page_key] = "cursor"
Pagy::OPTIONS[:limit] = 20
