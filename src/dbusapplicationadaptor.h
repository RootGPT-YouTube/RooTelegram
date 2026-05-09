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

#ifndef DBUSAPPLICATIONADAPTOR_H
#define DBUSAPPLICATIONADAPTOR_H

#include <QDBusAbstractAdaptor>
#include <QVariantList>
#include <QVariantMap>

class DBusAdaptor;

class DBusApplicationAdaptor : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Application")

public:
    explicit DBusApplicationAdaptor(DBusAdaptor *dbusAdaptor, QObject *parent = nullptr);

public slots:
    void Activate(const QVariantMap &platformData);
    void Open(const QStringList &uris, const QVariantMap &platformData);
    void ActivateAction(const QString &actionName, const QVariantList &parameter, const QVariantMap &platformData);

private:
    DBusAdaptor *dbusAdaptor;
};

#endif // DBUSAPPLICATIONADAPTOR_H
