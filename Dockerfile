FROM amazoncorretto:17-al2023-jdk

# Just matched `app/build.gradle`
ENV ANDROID_COMPILE_SDK "33"
# Just matched `app/build.gradle`
ENV ANDROID_BUILD_TOOLS "33.0.2"
# Version from https://developer.android.com/studio/releases/sdk-tools
ENV ANDROID_SDK_TOOLS "26.1.1"

ENV GEM_HOME="/usr/local/bundle"

ENV ANDROID_HOME "${PWD}/android-sdk"
ENV PATH="${GEM_HOME}/bin:${GEM_HOME}/gems/bin:${PATH}:/android-sdk/tools/bin:/usr/bin/bundle"
ENV ANDROID_SDK_ROOT="${PWD}/android-home"

RUN unset BUNDLE_PATH
RUN unset BUNDLE_BIN

# install OS packages
RUN dnf --quiet update -y
RUN dnf --quiet install git libxcrypt-compat which wget tar unzip ruby ruby-irb ruby-devel make automake gcc gcc-c++ kernel-devel -y


# install Android SDK
RUN wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip -d android-sdk android-sdk.zip

RUN mv android-sdk/cmdline-tools android-sdk/latest
RUN mkdir android-sdk/cmdline-tools
RUN mv android-sdk/latest android-sdk/cmdline-tools/latest

RUN android-sdk/cmdline-tools/latest/bin/sdkmanager --version
RUN yes | android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses || true
RUN android-sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"
RUN android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools"
RUN android-sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"

#remove android-sdk.zip
RUN rm android-sdk.zip


# install Fastlane
COPY Gemfile.* .
COPY Gemfile .

#Install bundler and fastlane
RUN gem install bundler
RUN bundle install