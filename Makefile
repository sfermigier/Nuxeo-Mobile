	SDK_VERSION=1.5.1
	SDK_HOME=$(HOME)/Library/Application Support/Titanium/mobilesdk/osx/$(SDK_VERSION)
	IOS_BUILDER=$(SDK_HOME)/iphone/builder.py
	IOS_VERSION=4.2
	UUID=FE6D0AF3-EF8C-4DA7-B32E-1144A1416098
	DEV_ID=Stefane Fermigier (N6XFBZ44WD)
	APP_ID=com.nuxeo.inuxeo
	APP_NAME=iNuxeo

	ANDROID_BUILDER=$(SDK_HOME)/android/builder.py
	ANDROID_HOME=$(HOME)/apps/android-sdk-mac_x86

	HERE=$(shell pwd)

defaut: test-ios

compile:
	coffee -c src/coffee/*.coffee
	mv src/coffee/*.js Resources/
	cp src/lib/*.js Resources/
	cp src/js/*.js Resources/
	#cp Resources/iphone/* build/iphone/Resources/

test-ios: compile
	python "$(IOS_BUILDER)" run . $(IOS_VERSION)

test-android: compile
	python "$(ANDROID_BUILDER)" simulator "$(APP_NAME)" "$(ANDROID_HOME)" \
		"$(HERE)" "$(APP_ID)" 7 HVGA

start-emulator:
	python "$(ANDROID_BUILDER)" emulator "$(APP_NAME)" "$(ANDROID_HOME)" \
		"$(HERE)" "$(APP_ID)" 7 HVGA > /dev/null 2>&1 &

install-ios:
	python "$(IOS_BUILDER)" install "$(IOS_VERSION)" $(HERE) \
		"$(APP_ID)" "$(APP_NAME)" $(UUID) "$(DEV_ID)" iphone

distribute-ios:
	python "$(IOS_BUILDER)" distribute $(IOS_VERSION) "$(HERE)" \
		$(APP_ID) $(APP_NAME) $(UUID) null "$(HERE)" iphone

clean:
	rm -rf build
	rm -f Resources/*.js
