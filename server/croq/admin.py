from django.contrib import admin
from django.db.models import TextField
from django.forms.widgets import Textarea
from pagedown.widgets import AdminPagedownWidget
from . import models


@admin.register(models.Country)
class CountryAdmin(admin.ModelAdmin):
    list_display = ["slug", "name"]
    list_display_links = ["slug", "name"]
    fieldsets = (
        (None, {
            "fields": ['name', 'slug'],
        }), 
        # ("Detalhes", {
        #     "fields": ['description'],
        # })
    )
class TabularInline(admin.TabularInline):
    formfield_overrides = { TextField: { "widget": Textarea(attrs={"rows": 3}) } }
    extra = 1

class AttractionInline(TabularInline):
    model = models.Attraction
    fields = ["name", "latlon", "description", "how_to_access"]



class RouteInline(TabularInline):
    model = models.Route
    fields = ["name", "grade", "latlon", "description"]
    

class SectorAdmin(admin.ModelAdmin):
    list_display = ["country", "region", "name"]
    list_display_links = ["name"]
    list_filter = ["region"]
    list_select_related = ["region", "region__country"]
    search_fields = ["name", "region__name", "region__country__name"] 
    fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ('name', 'region', 'latlon')
,        }), 
        ("Detalhes", {
            "classes": ("wide",),
            "fields": ('description', 'how_to_access'),
        })
    )
    formfield_overrides = {
        TextField: { "widget": AdminPagedownWidget(attrs={"rows": 4}) }
    }

    @admin.display(description='País')
    def country(self, obj):
        return obj.region.country


@admin.register(models.Region)
class RegionAdmin(admin.ModelAdmin):
    list_display = ["country", "name"]
    list_display_links = ["name"]
    list_filter = ["country"]
    list_select_related = ["country"]
    search_fields = ["name", "country__name", "description"]
    inlines = [AttractionInline]
    fieldsets = (
        (None, {
            "fields": ['name', 'latlon'],
        }), 
        ("Detalhes", {
            "classes": ["wide", "collapse"],
            "fields": ['description', "how_to_access"],
        })
    )
    formfield_overrides = {
        TextField: { "widget": AdminPagedownWidget(attrs={"rows": 4}) }
    }


@admin.register(models.RouteSector)
class RouteSectorAdmin(SectorAdmin):
    inlines = [RouteInline]

