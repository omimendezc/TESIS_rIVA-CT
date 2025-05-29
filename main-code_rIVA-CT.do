// CARGA DE BASE DE DATOS
import excel "C:\Usuario\Tesis\datos_IVAGeneral_LaPaz.xlsx", firstrow clear

// DEFINIR LA SERIE TEMPORAL
gen fecha = ym(año, mes)
format fecha %tm
tsset fecha

// GENERACIÓN DE VARIABLES EXPLICATIVAS
gen dummy_siat = fecha >= ym(2022, 7)
gen ratio_recaudacion = recaudacion_iva / num_contribuyentes
gen interaccion = dummy_siat * num_contribuyentes

// REGRESIÓN LINEAL MÚLTIPLE CON DUMMY E INTERACCIÓN
reg recaudacion_iva num_contribuyentes ratio_recaudacion dummy_siat interaccion

// PRUEBAS DE MULTICOLINEALIDAD
correlate num_contribuyentes ratio_recaudacion dummy_siat interaccion
vif

// PRUEBA DE HETEROCEDASTICIDAD (WHITE)
estat hettest

// PRUEBA DE AUTOCORRELACIÓN DE RESIDUALES
estat dwatson
estat bgodfrey

// TEST DE CHOW PARA RUPTURA ESTRUCTURAL EN JULIO 2022
gen post_siat = fecha >= ym(2022, 7)
gen grupo = cond(post_siat == 1, 2, 1)
reg recaudacion_iva num_contribuyentes if grupo == 1
est store antes
reg recaudacion_iva num_contribuyentes if grupo == 2
est store despues
suest antes despues
test [antes_mean]num_contribuyentes = [despues_mean]num_contribuyentes
