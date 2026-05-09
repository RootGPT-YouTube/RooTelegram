/*  
    Copyright (C) 2026 Sebastian J. Wolf and other contributors

    This file is part of RooTelegram.

    RooTelegram is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    RooTelegram is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with RooTelegram. If not, see <http://www.gnu.org/licenses/>.
*/

#include "dbusapplicationadaptor.h"
#include "dbusadaptor.h"

#define DEBUG_MODULE DBusApplicationAdaptor
#include "debuglog.h"

DBusApplicationAdaptor::DBusApplicationAdaptor(DBusAdaptor *dbusAdaptor, QObject *parent) :
    QDBusAbstractAdaptor(parent),
    dbusAdaptor(dbusAdaptor)
{
}

void DBusApplicationAdaptor::Activate(const QVariantMap &platformData)
{
    Q_UNUSED(platformData)
    LOG("Freedesktop Activate requested");
    if (this->dbusAdaptor) {
        this->dbusAdaptor->triggerActivateApp();
    }
}

void DBusApplicationAdaptor::Open(const QStringList &uris, const QVariantMap &platformData)
{
    Q_UNUSED(platformData)
    LOG("Freedesktop Open requested" << uris);
    if (!this->dbusAdaptor) {
        return;
    }
    this->dbusAdaptor->triggerActivateApp();
    if (!uris.isEmpty()) {
        this->dbusAdaptor->triggerOpenUrl(uris.first());
    }
}

void DBusApplicationAdaptor::ActivateAction(const QString &actionName, const QVariantList &parameter, const QVariantMap &platformData)
{
    Q_UNUSED(actionName)
    Q_UNUSED(parameter)
    Q_UNUSED(platformData)
    LOG("Freedesktop ActivateAction requested");
    if (this->dbusAdaptor) {
        this->dbusAdaptor->triggerActivateApp();
    }
}
