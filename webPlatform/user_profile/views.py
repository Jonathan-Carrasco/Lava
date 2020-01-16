from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    return HttpResponse("<h1>Login</h1>")

def profile(request, profile_id):
    return HttpResponse("<h1>Profile " + str(profile_id) + " </h1>")
