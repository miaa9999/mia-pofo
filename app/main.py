from fastapi import Depends, FastAPI, Form, Request
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.db import Base, engine, get_db
from app.models import Todo


settings = get_settings()

app = FastAPI(title=settings.app_name)
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/", response_class=HTMLResponse)
def index(request: Request, db: Session = Depends(get_db)):
    todos = db.scalars(select(Todo).order_by(Todo.created_at.desc())).all()
    return templates.TemplateResponse(
        "index.html",
        {"request": request, "todos": todos, "app_name": settings.app_name},
    )


@app.post("/todos", response_class=HTMLResponse)
def create_todo(
    request: Request,
    title: str = Form(..., min_length=1, max_length=160),
    db: Session = Depends(get_db),
):
    todo = Todo(title=title.strip())
    db.add(todo)
    db.commit()
    db.refresh(todo)

    if request.headers.get("HX-Request"):
        return templates.TemplateResponse(
            "partials/todo_item.html",
            {"request": request, "todo": todo},
            status_code=201,
        )

    return RedirectResponse("/", status_code=303)


@app.get("/healthz")
def healthz():
    return {"status": "ok"}
