import re
from django.core.exceptions import ValidationError

V_SCALE_VALIDATOR = re.compile(r'V(?P<grade>B|[0-9]{1,2})(?P<halfway>\/[0-9]{1,2})?(?P<mod>\s+(hard|soft|[+-]))?')
FONT_VALIDATOR = re.compile(r'V(B|[0-9]{1,2})(\s+(hard|soft))?')


def boulder_grade_validator(value: str, _msg="Graduação inválida"):
    """
    Check if string is a valid bouldering grade.

    Accepts Fontaineblau and V-Grades. 
    """
    if (m := V_SCALE_VALIDATOR.match(value)):
        groups = m.groupdict()
        if groups["halfway"] and groups["mod"]:
            raise ValidationError(_msg)
        if (nxt := groups["halfway"]):
            prev = int(groups["grade"].replace("B", "-1"))
            nxt = int(nxt[1:])
            if nxt != prev + 1:
                raise ValidationError(_msg)
    else:
        # TODO: Check Fontainebleau scale 
        raise ValidationError(_msg)