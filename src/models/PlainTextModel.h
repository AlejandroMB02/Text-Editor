#ifndef PLAINTEXTMODEL_H
#define PLAINTEXTMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <vector>

class PlainTextModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(bool modified READ isModified NOTIFY modifiedChanged)

public:
    explicit PlainTextModel(QObject *parent = nullptr);

    // QAbstractListModel overrides
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // Roles
    enum Roles {
        LineRole = Qt::UserRole + 1
    };

    QHash<int, QByteArray> roleNames() const override;

    // Getters
    QString filePath() const;
    bool isModified() const;

    // Setters
    void setFilePath(const QString &path);

    // Operations
    Q_INVOKABLE bool load();
    Q_INVOKABLE bool save();
    Q_INVOKABLE void insertLine(int index, const QString &text);
    Q_INVOKABLE void removeLine(int index);
    Q_INVOKABLE void appendLine(const QString &text);

signals:
    void filePathChanged();
    void modifiedChanged();

private:
    QString m_filePath;
    std::vector<QString> m_lines;
    bool m_modified;

    void setModified(bool modified);
};

#endif // PLAINTEXTMODEL_H
