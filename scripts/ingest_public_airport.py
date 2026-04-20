
import pandas as pd



aero_publicos = pd.read_csv('C:\\Dev\\Zoomcamp\\final-project\\cadastro-de-aerodromos-civis-publicos.csv', sep=';', skiprows=1, on_bad_lines='skip', engine='python')