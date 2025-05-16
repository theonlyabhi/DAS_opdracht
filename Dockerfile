FROM python:3.9
# Voeg niet-root gebruiker 
RUN addgroup --system abhiapp
RUN adduser --system --ingroup abhiapp gebruiker
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
# Gebruik veilige user
USER gebruiker
CMD ["python", "app/main.py"]