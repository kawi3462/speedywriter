package main

import (
           "github.com/go-flutter-desktop/go-flutter"
	file_picker "github.com/miguelpruivo/flutter_file_picker/go"
	"github.com/go-flutter-desktop/plugins/shared_preferences"
	"github.com/go-flutter-desktop/plugins/path_provider"
	"github.com/go-flutter-desktop/plugins/image_picker"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(&file_picker.FilePickerPlugin{}),
	flutter.AddPlugin(&shared_preferences.SharedPreferencesPlugin{
		VendorName:      "speedywriters",
		ApplicationName: "lastminutessay",
	}),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
		VendorName:      "myOrganizationOrUsername",
		ApplicationName: "myApplicationName",
	}),
	flutter.AddPlugin(&image_picker.ImagePickerPlugin{}),
 

}
