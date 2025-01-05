
# Heroicons Reason React

This is a simple project wrapping the [heroicons](https://heroicons.com) React bindings in ReasonML. 

## Quick Start

To install:
```shell
opam install heroicons-reason-react
npm install @heroicons/react # Must be >= 2.2.0
```
Now you can include `heroicons-reason-react` in your libraries in the appropriate dune file and do something like: 
```reason
...
<Heroicons.S16.Solid.AcademicCap
  className="some-class"
/>
...
```

## Contributing

This is a quite simple repository, though contributions are welcome. The code to generate the wrappers all resides within the `generate/` directory. Calling `dune exec -- generator` will create the wrapper code. Feel free to open any issues and I'll help where I can. 
