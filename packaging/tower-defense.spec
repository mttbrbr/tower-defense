%global debug_package %{nil}

Name:           tower-defense
Version:        1.0.0
Release:        1%{?dist}
Summary:        2D pixel-art tower defense prototype with 5 levels, 3 towers, and upgrades

License:        MIT and OFL-1.1
URL:            https://github.com/mttbrbr/tower-defense
Source0:        %{name}-%{version}.tar.gz
Source1:        %{name}.desktop
Source2:        icon.svg

# The exported Godot binary is dynamically linked against system libraries
# (libX11, libXcursor, libXinerama, libXext, libXfixes, libXi, libXrandr,
# libGL, libEGL, dbus-libs, glibc); RPM auto-generates those requires from
# the ELF. ALSA/PulseAudio/Wayland support is loaded at runtime.
Requires:       desktop-file-utils
Requires:       hicolor-icon-theme

%description
A 2D pixel-art tower defense prototype set across five Italian-inspired
locations. Build and upgrade towers, repel enemy waves, and use special
powers at the right time. Powered by the Godot 4 engine.

%prep
%autosetup

%build
# The game binary is already exported by Godot: see packaging/build-rpm.sh

%install
install -Dm 0755 TowerDefense.x86_64 %{buildroot}%{_libexecdir}/%{name}/%{name}
install -d -m 0755 %{buildroot}%{_bindir}
ln -sr %{_libexecdir}/%{name}/%{name} %{buildroot}%{_bindir}/%{name}
install -Dm 0644 -t %{buildroot}%{_datadir}/applications %{SOURCE1}
install -Dm 0644 %{SOURCE2} %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg

%files
%license LICENSE THIRD_PARTY_NOTICES.md
%doc README.md
%{_bindir}/%{name}
%{_libexecdir}/%{name}/
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg

%changelog
* Wed Sep 16 2026 mttbrbr <mttbrbr@users.noreply.github.com> - 1.0.0-1
- Initial RPM packaging for RHEL
