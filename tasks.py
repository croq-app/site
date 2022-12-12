from invoke import task


def manage(ctx, cmd, *args, **kwargs):
    return ctx.run(f"source server/env/bin/activate && python server/manage.py {cmd}", *args, **kwargs)

@task
def build(ctx, compress=False):
    """
    Build and maybe compress assets.
    """

    if compress:
        # ctx.run("sassc src/css/main.scss | cleancss -O3 > static/main.css")
        ctx.run("elm make src/elm/Main.elm --optimize --output=static/app.js")
        ctx.run(
            "uglifyjs static/app.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output static/app.js"
        )
        ctx.run("python data/extract.py | jq -c > static/data.json")
    else:
        # ctx.run("sassc scss/main.scss static/main.css")
        ctx.run("elm make src/elm/Main.elm --output=static/app.js")
        ctx.run("python data/extract.py > static/data.json")

    ctx.run("cp main.html index.html")


@task
def dev(ctx, frontend=False, backend=False):
    """
    Starts development server
    """
    if frontend:
        ctx.run("npx vite", pty=True)
    elif backend:
        manage(ctx, "runserver", pty=True)
    else:
        vite = ctx.run("npx vite --port 8000", asynchronous=True)
        manage(ctx, "runserver 8001", pty=True)
        # ctx.run("devd /api/=http://localhost:7999 http://localhost:7998 -X")
        # django.kill()
        vite.join()


@task
def db(ctx, app=None, migrate=False):
    """
    Run database migrations.
    """
    suffix = "" if app is None else " " + app
    manage(ctx, "makemigrations" + suffix, pty=True)
    if migrate:
        manage(ctx, "migrate" + suffix, pty=True)
        

@task(build)
def preview(ctx):
    """
    Makes a build and serves a production-like version of the site.

    Live reload and hot reload are disabled and assets are compressed.
    """
    ctx.run("python -m http.server 8001")


@task
def publish(ctx, message=None, skip_checks=False):
    """
    Publish site in github.
    """
    ctx.run("black .")
    ctx.run("elm-format src/ --yes")
    if not skip_checks:
        check(ctx)
        build(ctx, compress=True)

    ctx.run("git add .")
    ctx.run("git status", pty=True)
    if not message:
        print("-" * 40)
        message = input("Commit message: ")
    ctx.run(f'git commit -m "{message}"')
    ctx.run("git push")


@task(build)
def check(ctx):
    """
    Run sanity checks.
    """
    ctx.run("python data/check_links.py")
