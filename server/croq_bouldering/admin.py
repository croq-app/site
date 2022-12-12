from django.contrib import admin
from django.db.models import TextField
from django.forms.widgets import Textarea
from pagedown.widgets import AdminPagedownWidget

from croq.admin import TabularInline, SectorAdmin
from . import models

class BoulderBlockInline(TabularInline):
    model = models.BoulderFormation
    fields = ["name", "latlon", "description"]


class BoulderProblemInline(TabularInline):
    model = models.BoulderProblem
    fields = ["name", "grade", "latlon", "description", "video_csv", "must_do", "is_highball", "is_dangerous",]


@admin.register(models.BoulderingSector)
class BoulderingSectorAdmin(SectorAdmin):
    inlines = [BoulderBlockInline]


@admin.register(models.BoulderFormation)
class BoulderAdmin(admin.ModelAdmin):
    list_display = ["country", "region", "sector", "name"]
    list_display_links = ["name"]
    list_filter = ["sector", "sector__region", "sector__region__country"]
    list_select_related = ["sector", "sector__region", "sector__region__country"]
    search_fields = ["name", "region__name", "region__country__name"] 
    fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ('name', 'sector', 'latlon')
,        }), 
        ("Detalhes", {
            "classes": ("wide",),
            "fields": ('description', 'how_to_access'),
        })
    )
    inlines = [BoulderProblemInline]
    formfield_overrides = {
        TextField: { "widget": AdminPagedownWidget(attrs={"rows": 4}) }
    }

    @admin.display(description='País')
    def country(self, obj):
        return obj.sector.region.country

    @admin.display(description='País')
    def region(self, obj):
        return obj.sector.region
