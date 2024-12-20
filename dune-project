(lang dune 3.8)

(using melange 0.1)

(name heroicons-reason-react)

; Because we need to add a custom build step in the opam file of
; `dune build @generate_code`, we don't generate the opam file
; (generate_opam_files true)
 
(version 1.0)

(source
 (github benbellick/heroicons-reason-react)) 
 
(license "MIT")

(authors "Ben Bellick <benbellick@pm.me>")

(maintainers "Ben Bellick <benbellick@pm.me>")

(documentation https://github.com/benbellick/heroicons-reason-react) 

(homepage https://github.com/benbellick/heroicons-reason-react)

(bug_reports https://github.com/benbellick/heroicons-reason-react/issues)

(package
 (name heroicons-reason-react)
 (synopsis "ReasonML bindings to the Heroicons React components")
 (depends
   ocaml
  (reason (>= 3.13.0))
  (dune (>= 3.8))
  (melange (>= 4.0.0))
  (reason-react (>= 0.15.0))
   reason-react-ppx)
 (tags
  ("heroicons" "icons" "reason" "react")))
