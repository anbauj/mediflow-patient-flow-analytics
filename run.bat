@echo off
echo Starting MediFlow Outpatient Flow Dashboard...
cd /d "%~dp0"
python -m streamlit run app/main.py --server.port 8501 --server.address 0.0.0.0
pause
