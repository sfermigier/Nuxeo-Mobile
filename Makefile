# Edit this to fit your own profiles and ids.
	SDK_VERSION=1.5.1
	IOS_VERSION=4.2
	DIST_UUID=D3023DD0-FB15-46A4-89B8-E2ECC08C919B
	TEST_UUID=B8687100-9AEB-4EF1-9059-60F946F2F14C
	DEV_ID=Stefane Fermigier (N6XFBZ44WD)
	APP_ID=com.nuxeo.mobile
	APP_NAME=NuxeoMobile
	DIST_CERT=Nuxeo

# Don't touch
	SDK_HOME=$(HOME)/Library/Application Support/Titanium/mobilesdk/osx/$(SDK_VERSION)
	IOS_BUILDER=$(SDK_HOME)/iphone/builder.py

	ANDROID_BUILDER=$(SDK_HOME)/android/builder.py
	ANDROID_HOME=$(HOME)/apps/android-sdk-mac_x86

	HERE=$(shell pwd)

defaut: test-ios

compile:
	coffee -c src/coffee/*.coffee
	mv src/coffee/*.js Resources/
	cp src/lib/*.js Resources/
	cp src/js/*.js Resources/

test-ios: compile
	python "$(IOS_BUILDER)" run . $(IOS_VERSION)

test-android: compile
	python "$(ANDROID_BUILDER)" simulator "$(APP_NAME)" "$(ANDROID_HOME)" \
		"$(HERE)" "$(APP_ID)" 8 HVGA

start-emulator:
	python "$(ANDROID_BUILDER)" emulator "$(APP_NAME)" "$(ANDROID_HOME)" \
		"$(HERE)" "$(APP_ID)" 8 HVGA > /dev/null 2>&1 &

install-ios:
	python "$(IOS_BUILDER)" install "$(IOS_VERSION)" $(HERE) \
		"$(APP_ID)" "$(APP_NAME)" $(TEST_UUID) "$(DEV_ID)" iphone

distribute-ios:
	python "$(IOS_BUILDER)" distribute $(IOS_VERSION) "$(HERE)" \
		$(APP_ID) "$(APP_NAME)" $(DIST_UUID) "$(DIST_CERT)" "$(HERE)" iphone

clean:
	rm -rf build

superclean: clean
	rm -f Resources/*.js
