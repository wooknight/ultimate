package finance

import "math"

func Simple_cash_flow(pv float64, discount_rate float64, period float64) float64 {
	fv := pv / math.Pow(1+discount_rate/100.00, period)
	return fv
}

func Annuity(pv float64, discount_rate float64, period float64) float64 {
	fv := (1 - 1/math.Pow(1+discount_rate/100.00, period)) / discount_rate
	return fv
}
