// ========================================================
// ANÁLISIS DE LA CULTURA TRIBUTARIA DE LOS CONTRIBUYENTES EN RÉGIMEN GENERAL 
// Y SU EFECTO EN LA RECAUDACIÓN DEL IVA EN LA CIUDAD DE LA PAZ
// Modelo MCO con variable dummy estructural y análisis de series temporales
// Autor: Omar Joel Mendez Condori – Tesis de Grado
// Fecha: 28-05-2025
// ========================================================

// --------------------------
// 1. CARGA DE BASE DE DATOS
// --------------------------
import excel "C:\Users\omarm\OneDrive\Desktop\codigo.stata.rIVA-CT\datos_cumplimiento_IVA_LaPaz.xlsx", firstrow clear

// --------------------------
// 2. DEFINICIÓN DE SERIE TEMPORAL
// --------------------------
gen fecha = ym(año, mes)         // Construye variable de tiempo mensual (formato Stata)
format fecha %tm
tsset fecha                       // Declara estructura temporal de los datos

// --------------------------
// 3. CONSTRUCCIÓN DE VARIABLES EXPLICATIVAS
// --------------------------
gen ratio_recaudacion = r_total / total_contribuyentes              // Proxy de eficiencia fiscal

// DUMMY PRINCIPAL: Implementación del SIAT en Línea – RND 102000000022 (septiembre 2022)
gen dummy_siat = fecha >= ym(2022, 9)

// DUMMY adicional 1: Obligación de facturación electrónica 4to grupo – RND 102300000016 (mayo 2023)
gen dummy_factu4 = fecha >= ym(2023, 5)

// DUMMY adicional 2: Respaldo bancario para operaciones mayores a Bs 50.000 – RND 102400000021 (septiembre 2024)
gen dummy_banco = fecha >= ym(2024, 9)

// DUMMY adicional 3: Control a beneficiarios del régimen Tasa Cero – RND 102400000015 (abril 2024)
gen dummy_tasacero = fecha >= ym(2024, 4)

// INTERACCIÓN con dummy principal para capturar cambio estructural
gen interaccion_siat = dummy_siat * total_contribuyentes

// --------------------------
// 4. ESTIMACIÓN DEL MODELO MCO CON DUMMIES MULTIPLES
// --------------------------
reg r_total total_contribuyentes ratio_recaudacion dummy_siat interaccion_siat ///
    dummy_factu4 dummy_banco dummy_tasacero

// --------------------------
// 5. PRUEBA DE MULTICOLINEALIDAD
// --------------------------
correlate total_contribuyentes ratio_recaudacion dummy_siat interaccion_siat ///
          dummy_factu4 dummy_banco dummy_tasacero
vif    // Verifica inflación de la varianza; VIF > 10 indica multicolinealidad problemática

// --------------------------
// 6. PRUEBA DE HETEROCEDASTICIDAD (WHITE TEST)
// --------------------------
estat hettest    // Verifica si los residuos tienen varianza constante (homocedasticidad)

// --------------------------
// 7. PRUEBAS DE AUTOCORRELACIÓN DE RESIDUALES
// --------------------------
estat dwatson     // Prueba Durbin-Watson (autocorrelación de primer orden)
estat bgodfrey    // Prueba Breusch-Godfrey (autocorrelación de orden superior)

// --------------------------
// 8. TEST DE CHOW PARA RUPTURA ESTRUCTURAL (septiembre 2022 – SIAT)
// --------------------------
gen grupo = cond(dummy_siat == 1, 2, 1)

reg r_total total_contribuyentes if grupo == 1
est store antes

reg r_total total_contribuyentes if grupo == 2
est store despues

suest antes despues
test [antes_mean]total_contribuyentes = [despues_mean]total_contribuyentes

// --------------------------
// FIN DEL CÓDIGO
// --------------------------
