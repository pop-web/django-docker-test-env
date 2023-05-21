from django.shortcuts import render


def hello_world(request):
    return render(request, "myapp/hello_world.html", {"message": "Hello, World!"})
