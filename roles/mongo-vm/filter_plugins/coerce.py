"""
Coerce operators for Jinja
"""

class FilterModule(object):
    """
    Coerce operators for Jinja
    """
    def filters(self):
        return {
            'coerce_list': self.coerce_list
        }

    def coerce_list(self, string_or_array):
        if type(string_or_array) is list:
            return string_or_array
        else:
            return [string_or_array]
