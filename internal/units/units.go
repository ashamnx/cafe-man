package units

import (
	"fmt"
	"strings"

	"searlo-cafe/internal/model"
)

// Resolve matches a free-text unit string (e.g. "kg", "Kilogram", "grams")
// against the known units by case-insensitive abbreviation or name. Returns nil
// when no match is found so callers can leave bill_unit_id NULL.
func Resolve(raw string, units []model.Unit) *model.Unit {
	needle := strings.ToLower(strings.TrimSpace(raw))
	if needle == "" {
		return nil
	}
	needle = strings.TrimSuffix(needle, "s")
	for i, u := range units {
		a := strings.ToLower(u.Abbreviation)
		n := strings.TrimSuffix(strings.ToLower(u.Name), "s")
		if a == needle || n == needle {
			return &units[i]
		}
	}
	return nil
}

func factor(u *model.Unit) float64 {
	if u.ConversionFactor != nil {
		return *u.ConversionFactor
	}
	return 1.0
}

// ErrTypeMismatch is returned when two units don't share the same unit_type
// (e.g. converting a weight to a volume).
type ErrTypeMismatch struct {
	From *model.Unit
	To   *model.Unit
}

func (e *ErrTypeMismatch) Error() string {
	return fmt.Sprintf("cannot convert %s (%s) to %s (%s)", e.From.Abbreviation, e.From.UnitType, e.To.Abbreviation, e.To.UnitType)
}

// ConvertQuantity converts a quantity from one unit to another.
// Returns an error when units have different unit_types.
func ConvertQuantity(qty float64, from, to *model.Unit) (float64, error) {
	if from.ID == to.ID {
		return qty, nil
	}
	if from.UnitType != to.UnitType {
		return 0, &ErrTypeMismatch{From: from, To: to}
	}
	return qty * (factor(from) / factor(to)), nil
}

// ConvertPrice converts a per-unit price from one unit to another.
// Returns an error when units have different unit_types.
func ConvertPrice(price float64, from, to *model.Unit) (float64, error) {
	if from.ID == to.ID {
		return price, nil
	}
	if from.UnitType != to.UnitType {
		return 0, &ErrTypeMismatch{From: from, To: to}
	}
	return price * (factor(to) / factor(from)), nil
}

// BestDisplay picks the most human-readable unit for a quantity stored in
// baseUnit. E.g. 0.005 kg → (5, gram). If no better unit exists (count types,
// or qty >= 1 in the base unit), returns the base unit and original qty.
func BestDisplay(qty float64, base *model.Unit, allUnits []model.Unit) (*model.Unit, float64) {
	if qty == 0 || base.UnitType == "count" {
		return base, qty
	}

	best := base
	bestQty := qty

	for i, u := range allUnits {
		if u.UnitType != base.UnitType || u.ID == base.ID {
			continue
		}
		converted, err := ConvertQuantity(qty, base, &allUnits[i])
		if err != nil {
			continue
		}
		// Prefer the unit that produces a value >= 1 with the fewest
		// unnecessary decimal places. Among candidates >= 1, pick the
		// smallest (closest to the value).
		if converted >= 1 && (bestQty < 1 || converted < bestQty) {
			best = &allUnits[i]
			bestQty = converted
		}
	}
	return best, bestQty
}
