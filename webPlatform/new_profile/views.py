from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    return HttpResponse("<h1>New Profile</h1>")

def primary_info(request):
    return HttpResponse("<h1>Cell Number, Email, Name</h1>")
