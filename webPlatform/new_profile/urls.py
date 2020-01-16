from django.urls import path
from django.contrib import admin
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('primary_info/', views.primary_info, name='primary_ifo')
]
