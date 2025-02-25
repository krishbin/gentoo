# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson virtualx xdg

DESCRIPTION="A highly customizable and functional document viewer"
HOMEPAGE="https://pwmt.org/projects/zathura/"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.pwmt.org/pwmt/${PN}.git"
	EGIT_BRANCH="develop"
else
	SRC_URI="
		https://github.com/pwmt/zathura/archive/${PV}.tar.gz -> ${P}.tar.gz
		https://dev.gentoo.org/~slashbeast/distfiles/${PN}/${P}-manpages.tar.xz
	"
	KEYWORDS="~amd64 arm ~riscv ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="ZLIB"
SLOT="0/$(ver_cut 1-2)"
IUSE="seccomp sqlite synctex test"

RESTRICT="!test? ( test )"

DEPEND=">=dev-libs/girara-0.3.7
	>=dev-libs/glib-2.50:2
	>=sys-devel/gettext-0.19.8
	x11-libs/cairo
	>=x11-libs/gtk+-3.22:3
	sys-apps/file
	seccomp? ( sys-libs/libseccomp )
	sqlite? ( >=dev-db/sqlite-3.5.9:3 )
	synctex? ( app-text/texlive-core )"

RDEPEND="${DEPEND}"

BDEPEND="
	test? ( dev-libs/appstream-glib
		dev-libs/check )
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/zathura-disable-seccomp-tests.patch
)

src_configure() {
	local emesonargs=(
		-Dconvert-icon=disabled
		-Dmanpages=disabled
		-Dseccomp=$(usex seccomp enabled disabled)
		-Dsqlite=$(usex sqlite enabled disabled)
		-Dsynctex=$(usex synctex enabled disabled)
		)
	meson_src_configure
}

src_install() {
	meson_src_install
	doman "${WORKDIR}"/man/zathura*
}

src_test() {
	virtx meson_src_test
}
