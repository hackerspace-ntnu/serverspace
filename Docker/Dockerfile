# image base and version
FROM python:3.8.5-slim-buster

# enviroment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE 1

# Create directory
WORKDIR /code

RUN adduser django
RUN chown django:django /code
USER django
ENV PATH /home/django/.local/bin:$PATH
COPY --chown=django:django . ./

# Install requirements
RUN python -m pip install --upgrade pip
COPY requirements.txt .
COPY prod_requirements.txt .
RUN pip install -r prod_requirements.txt

# Copy repository to directory
COPY . .

# Setup start commands
RUN python manage.py migrate
CMD ["gunicorn","--bind","0.0.0.0:8000","website.wsgi"]
