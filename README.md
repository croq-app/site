CROCS
=====

A climbing APP with useful information and topos about crags, boulders, and routes. The live website can be accessed from http://crocs.github.io/site/


Local development environment
-----------------------------

The project uses nix with [direnv](https://direnv.net/). If your dev environment is properly configured], just `ls` to the project directory and let the magic happen. After nix builds the base environment, type ``inv configure`` to finish the configuration. ``inv dev`` starts the development server.


Tooling and tech stack
----------------------

Frontend:
* Elm for the main SPA
* TailwindCSS and [DaisyUI](https://daisyui.com/) for CSS
* [Lunrjs](https://lunrjs.com/) for static search
* Vite for packaging and other tooling 

Backend:
* FastAPI
* Tortoise ORM
* Invoke for scripts
